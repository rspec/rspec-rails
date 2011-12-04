require "action_dispatch/testing/assertions/routing"

module RSpec::Rails
  module RoutingExampleGroup
    extend ActiveSupport::Concern
    include RSpec::Rails::RailsExampleGroup
    include ActionDispatch::Assertions::RoutingAssertions
    include RSpec::Rails::Matchers::RoutingMatchers
    include RSpec::Rails::Matchers::RoutingMatchers::RouteHelpers

    module InstanceMethods
      
      def routes
        @routes ||= ::Rails.application.routes
      end

      private

      def method_missing(m, *args, &block)
        routes.url_helpers.respond_to?(m) ? routes.url_helpers.send(m, *args) : super
      end
    end

    included do
      metadata[:type] = :routing
    end
  end
end
