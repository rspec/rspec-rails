require "action_dispatch/testing/assertions/routing"

module RSpec
  module Rails
    # Container module for routing spec functionality.
    module RoutingExampleGroup
      extend ActiveSupport::Concern
      include RSpec::Rails::RailsExampleGroup
      include RSpec::Rails::Matchers::RoutingMatchers
      include RSpec::Rails::Matchers::RoutingMatchers::RouteHelpers
      include RSpec::Rails::AssertionDelegator.new(ActionDispatch::Assertions::RoutingAssertions)

      # Class-level DSL for route specs.
      module ClassMethods
        # Specifies the routeset that will be used for the example group. This
        # is most useful when testing Rails engines.
        #
        # @example
        #     describe MyEngine::PostsController do
        #       routes { MyEngine::Engine.routes }
        #
        #       it "routes posts#index" do
        #         expect(:get => "/posts").to
        #           route_to(:controller => "my_engine/posts", :action => "index")
        #       end
        #     end
        def routes(&blk)
          before do
            self.routes = blk.call
          end
        end
      end

      included do
        before do
          self.routes = ::Rails.application.routes
        end
      end

      attr_reader :routes

      # @private
      def routes=(routes)
        @routes = routes
        assertion_instance.instance_variable_set(:@routes, routes)
      end

    private

      def method_missing(m, *args, &block)
        routes.url_helpers.respond_to?(m) ? routes.url_helpers.send(m, *args) : super
      end
    end
  end
end
