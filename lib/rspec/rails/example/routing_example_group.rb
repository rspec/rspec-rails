require "action_dispatch/testing/assertions/routing"

module RSpec::Rails
  # Routing specs live in spec/routing. If `config/routes.rb` has nothing
  # beyond `map.resources :thing`, then you probably don't need a routing spec,
  # but they can be quite helpful when specifying non-standard routes.
  #
  # @example
  #
  #     require 'spec_helper'
  #
  #     describe "profiles routes" do
  #       it "routes /profiles/jdoe" do
  #         get("/profiles/jdoe").should route_to("profiles#show", :username => 'jdoe')
  #       end
  #     end
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
      metadata[:type] = :routing

      before do
        @routes = ::Rails.application.routes
      end
    end
  end
end
