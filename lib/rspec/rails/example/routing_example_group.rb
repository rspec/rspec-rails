require "action_dispatch/testing/assertions/routing"

module RSpec::Rails
  module RoutingExampleGroup
    extend ActiveSupport::Concern
    include RSpec::Rails::RailsExampleGroup
    include RSpec::Rails::Matchers::RoutingMatchers
    include RSpec::Rails::Matchers::RoutingMatchers::RouteHelpers
    include RSpec::Rails::AssertionDelegator.new(ActionDispatch::Assertions::RoutingAssertions)

    included do
      metadata[:type] = :routing

      before do
        self.routes = ::Rails.application.routes
      end
    end

    attr_reader :routes

    # Explicitly sets the routes. This is most often useful when testing a
    # routes for a Rails engine.
    #
    # @example
    #
    #     describe "MyEngine routing" do
    #       before { self.routes = MyEngine::Engine.routes }
    #
    #       # ...
    #     end
    def routes=(routes)
      @routes = routes
      assertion_instance.instance_variable_set(:@routes, @routes)
    end

    private

    def method_missing(m, *args, &block)
      routes.url_helpers.respond_to?(m) ? routes.url_helpers.send(m, *args) : super
    end
  end
end
