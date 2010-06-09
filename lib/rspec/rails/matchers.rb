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
  require "active_record"
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

RSpec::Matchers.define :be_a_new do |model_klass|
  match do |actual|
    model_klass === actual && actual.new_record?
  end
end

require 'rspec/matchers/have'

module RSpec #:nodoc:
  module Matchers #:nodoc:
    class Have #:nodoc:

      def failure_message_for_should_with_errors_on_extensions
        return "expected #{relativities[@relativity]}#{@expected} errors on :#{@args[0]}, got #{@actual}" if @collection_name == :errors_on
        return "expected #{relativities[@relativity]}#{@expected} error on :#{@args[0]}, got #{@actual}"  if @collection_name == :error_on
        return failure_message_for_should_without_errors_on_extensions
      end
      alias_method_chain :failure_message_for_should, :errors_on_extensions
      
      def description_with_errors_on_extensions
        return "have #{relativities[@relativity]}#{@expected} errors on :#{@args[0]}" if @collection_name == :errors_on
        return "have #{relativities[@relativity]}#{@expected} error on :#{@args[0]}"  if @collection_name == :error_on
        return description_without_errors_on_extensions
      end
      alias_method_chain :description, :errors_on_extensions

    end
  end
end

