require "action_dispatch/testing/assertions/routing"

module RSpec::Rails
  module RoutingExampleGroup
    extend ActiveSupport::Concern

    include RSpec::Rails::TestUnitAssertionAdapter
    include ActionDispatch::Assertions::RoutingAssertions
    include RSpec::Rails::RoutingSpecMatchers

    included do
      before do
        @routes = ::Rails.application.routes
      end
    end

    RSpec.configure do |c|
      c.include self, :example_group => { :file_path => /\bspec\/routing\// }
    end
  end
end
