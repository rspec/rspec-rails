require 'active_support/concern'
require 'rspec/rails/adapters/assertions'

module RSpec::Rails::Adapters
  module TestUnitAssertionAdapter
    extend ActiveSupport::Concern

    module ClassMethods
      # @api private
      #
      # Returns the names of assertion methods that we want to expose to
      # examples without exposing non-assertion methods in Test::Unit or
      # Minitest.
      def assertion_method_names
        ::RSpec::Rails::Adapters::Assertions.public_instance_methods.select{|m| m.to_s =~ /^(assert|flunk)/} +
          [:build_message]
      end

      # @api private
      def define_assertion_delegators
        assertion_method_names.each do |m|
          class_eval <<-CODE, __FILE__, __LINE__ + 1
              def #{m}(*args, &block)
                assertion_delegator.send :#{m}, *args, &block
              end
          CODE
        end
      end
    end

    class AssertionDelegator
      include ::RSpec::Rails::Adapters::Assertions
      include ::RSpec::Rails::Adapters::MinitestCounters
    end

    # @api private
    def assertion_delegator
      @assertion_delegator ||= AssertionDelegator.new
    end

    included do
      define_assertion_delegators
    end
  end
end
