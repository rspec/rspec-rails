require 'action_view/testing/resolvers'

module RSpec
  module Rails
    # @api public
    # Helpers for optionally rendering views in controller specs.
    module ViewRendering
      extend ActiveSupport::Concern

      # @!attribute [r]
      # Returns the controller object instance under test.
      attr_reader :controller

      # @private
      attr_writer :controller
      private :controller=

      # DSL methods
      module ClassMethods
        # @see RSpec::Rails::ControllerExampleGroup
        def render_views(true_or_false = true)
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
      class EmptyTemplateResolver < ::ActionView::FileSystemResolver
      private

        def find_templates(*args)
          super.map do |template|
            ::ActionView::Template.new(
              "",
              template.identifier,
              EmptyTemplateHandler,
              :virtual_path => template.virtual_path,
              :format => template.formats
            )
          end
        end
      end

      # @private
      class EmptyTemplateHandler
        def self.call(_template)
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
          EmptyTemplateResolver.new(path)
        end
      end

      # @private
      RESOLVER_CACHE = Hash.new do |hash, path|
        hash[path] = EmptyTemplateResolver.new(path)
      end

      included do
        before do
          unless render_views?
            @_original_path_set = controller.class.view_paths
            path_set = @_original_path_set.map { |resolver| RESOLVER_CACHE[resolver.to_s] }

            controller.class.view_paths = path_set
            controller.extend(EmptyTemplates)
          end
        end

        after do
          controller.class.view_paths = @_original_path_set unless render_views?
        end
      end
    end
  end
end
