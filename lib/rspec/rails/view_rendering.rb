require 'action_view/testing/resolvers'

module RSpec
  module Rails
    # Helpers for optionally rendering views in controller specs.
    module ViewRendering
      extend ActiveSupport::Concern

      attr_accessor :controller

      # DSL methods
      module ClassMethods
        # @see RSpec::Rails::ControllerExampleGroup
        def render_views(true_or_false=true)
          @render_views = true_or_false
        end

        # @api private
        def render_views?
          return @render_views if defined?(@render_views)

          if superclass.respond_to?(:render_views?)
            superclass.render_views?
          else
            RSpec.configuration.render_views?
          end
        end
      end

      # @api private
      def render_views?
        self.class.render_views? || !controller.class.respond_to?(:view_paths)
      end

      # Delegates find_all to the submitted path set and then returns templates
      # with modified source
      #
      # @private
      class EmptyTemplatePathSetDecorator < ::ActionView::Resolver
        attr_reader :original_path_set

        def initialize(original_path_set)
          @original_path_set = original_path_set
        end

        def find_all(*args)
          original_path_set.find_all(*args).collect do |template|
            ::ActionView::Template.new(
              "",
              template.identifier,
              EmptyTemplateHandler,
              {
                :virtual_path => template.virtual_path,
                :format => template.formats
              }
            )
          end
        end
      end

      # @private
      class EmptyTemplateHandler
        def self.call(template)
          %("")
        end
      end

      # Used to null out view rendering in controller specs.
      #
      # @private
      module EmptyTemplates
        def prepend_view_path(new_path)
          lookup_context.view_paths.unshift(*_path_decorator(new_path))
        end

        def append_view_path(new_path)
          lookup_context.view_paths.push(*_path_decorator(new_path))
        end

        private

        def _path_decorator(path)
          EmptyTemplatePathSetDecorator.new(ActionView::PathSet.new(Array.wrap(path)))
        end
      end

      included do
        before do
          unless render_views?
            @_empty_view_path_set_delegator = EmptyTemplatePathSetDecorator.new(controller.class.view_paths)
            controller.class.view_paths = ::ActionView::PathSet.new.push(@_empty_view_path_set_delegator)
            controller.extend(EmptyTemplates)
          end
        end

        after do
          unless render_views?
            controller.class.view_paths = @_empty_view_path_set_delegator.original_path_set
          end
        end
      end
    end
  end
end
