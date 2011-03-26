require "action_dispatch/testing/assertions/routing"
require 'rspec/rails/example/routing_example_group/describe_with_request_pair_support'

module RSpec::Rails
  module RoutingExampleGroup
    extend ActiveSupport::Concern
    include RSpec::Rails::RailsExampleGroup
    include ActionDispatch::Assertions::RoutingAssertions
    include RSpec::Rails::Matchers::RoutingMatchers
    include RSpec::Rails::Matchers::RoutingMatchers::RouteHelpers

    module InstanceMethods
      attr_reader :routes

      private

      def method_missing(m, *args, &block)
        routes.url_helpers.respond_to?(m) ? routes.url_helpers.send(m, *args) : super
      end
    end

    included do
      extend RSpec::Rails::Matchers::RoutingMatchers::RouteHelpers
      extend DescribeWithRequestPairSupport
      metadata[:type] = :routing

      before do
        @routes = ::Rails.application.routes
      end
    end
  end
end
