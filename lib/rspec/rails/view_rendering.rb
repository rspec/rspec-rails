require 'action_view/testing/resolvers'

RSpec.configure do |config|
  config.add_setting :render_views, :default => false

  # TODO - rspec-core needs a way to define a setting that works like this in
  # one go
  def config.render_views
    settings[:render_views] = true
  end

  def config.render_views?
    settings[:render_views]
  end
end

module RSpec
  module Rails
    module ViewRendering
      extend ActiveSupport::Concern

      attr_accessor :controller

      module ClassMethods
        def metadata_for_rspec_rails
          metadata[:rspec_rails] = metadata[:rspec_rails] ? metadata[:rspec_rails].dup : {}
        end

        # See RSpec::Rails::ControllerExampleGroup
        def render_views(true_or_false=true)
          metadata_for_rspec_rails[:render_views] = true_or_false
        end

        def integrate_views
          RSpec.deprecate("integrate_views","render_views")
          render_views
        end

        def render_views?
          metadata_for_rspec_rails[:render_views] || RSpec.configuration.render_views?
        end
      end

      module InstanceMethods
        def render_views?
          self.class.render_views? || !controller.class.respond_to?(:view_paths)
        end
      end

      # Delegates find_all to the submitted path set and then returns templates
      # with modified source
      class PathSetDelegatorResolver < ::ActionView::Resolver
        attr_reader :path_set

        def initialize(path_set)
          @path_set = path_set
        end

        def find_all(*args)
          path_set.find_all(*args).collect do |template|
            ::ActionView::Template.new(
              "",
              template.identifier,
              template.handler,
              {
                :virtual_path => template.virtual_path,
                :format => template.formats
              }
            )
          end
        end
      end

      included do
        before do
          unless render_views?
            @_path_set_delegator_resolver = PathSetDelegatorResolver.new(controller.class.view_paths)
            controller.class.view_paths = ::ActionView::PathSet.new.push(@_path_set_delegator_resolver)
            controller.instance_eval do
              alias orig_prepend_view_path prepend_view_path
              alias orig_append_view_path append_view_path

              def prepend_view_path(new_path)
                _new_path_delegator = PathSetDelegatorResolver.new(::ActionView::FileSystemResolver.new(new_path))
                lookup_context.view_paths.unshift(*_new_path_delegator)
              end

              def append_view_path(new_path)
                _new_path_delegator = PathSetDelegatorResolver.new(::ActionView::FileSystemResolver.new(new_path))
                lookup_context.view_paths.push(*_new_path_delegator)
              end
            end
          end
        end

        after do
          unless render_views?
            controller.class.view_paths = @_path_set_delegator_resolver.path_set
            controller.instance_eval do
              alias prepend_view_path orig_prepend_view_path
              alias append_view_path orig_append_view_path
            end
          end
        end
      end

    end
  end
end
