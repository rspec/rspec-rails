require "action_dispatch/testing/assertions/routing"

module RSpec::Rails
  module RoutingExampleGroup
    extend ActiveSupport::Concern
    extend RSpec::Rails::ModuleInclusion

    include RSpec::Rails::TestUnitAssertionAdapter
    include ActionDispatch::Assertions::RoutingAssertions
    include RSpec::Rails::Matchers::RoutingMatchers

    module InstanceMethods
      attr_reader :routes
    end

    included do
      metadata[:type] = :routing

      before do
        @routes = ::Rails.application.routes
      end
    end

    RSpec.configure &include_self_when_dir_matches('spec','routing')
  end
end
