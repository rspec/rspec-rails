require 'rspec/core/deprecation'
require 'rspec/core/backward_compatibility'
require 'rspec/matchers'

begin
  require 'test/unit/assertionfailederror'
rescue LoadError
  module Test
    module Unit
      class AssertionFailedError < StandardError
      end
    end
  end
end

begin
  require "action_controller"
rescue LoadError
end

module RSpec::Rails
  module ControllerSpecMatchers
    extend RSpec::Matchers::DSL

    matcher :redirect_to do |destination|
      match_unless_raises Test::Unit::AssertionFailedError do |_|
        assert_redirected_to destination
      end

      failure_message_for_should do
        rescued_exception.message
      end
    end

    matcher :render_template do |options, message|
      match_unless_raises Test::Unit::AssertionFailedError do |_|
        options = options.to_s if Symbol === options
        assert_template options, message
      end

      failure_message_for_should do
        rescued_exception.message
      end
    end
  end
end
