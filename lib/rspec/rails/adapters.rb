require 'active_support/concern'
require 'test/unit/assertions'

module RSpec
  module Rails
    module SetupAndTeardownAdapter
      extend ActiveSupport::Concern

      module ClassMethods
        # @api private
        #
        # Wraps `setup` calls from within Rails' testing framework in `before`
        # hooks.
        def setup(*methods)
          methods.each do |method|
            if method.to_s =~ /^setup_(fixtures|controller_request_and_response)$/
              prepend_before { send method }
            else
              before         { send method }
            end
          end
        end

        # @api private
        #
        # Wraps `teardown` calls from within Rails' testing framework in
        # `after` hooks.
        def teardown(*methods)
          methods.each { |method| after { send method } }
        end
      end

      # @api private
      def method_name
        @example
      end
    end

    module TestUnitAssertionAdapter
      extend ActiveSupport::Concern

      module ClassMethods
        # @api private
        #
        # Returns the names of assertion methods that we want to expose to
        # examples without exposing non-assertion methods in Test::Unit or
        # Minitest.
        def assertion_method_names
          Test::Unit::Assertions.public_instance_methods.select{|m| m.to_s =~ /^(assert|flunk)/} +
            [:build_message]
        end

        # @api private
        def define_assertion_delegators
          assertion_method_names.each do |m|
            class_eval <<-CODE
              def #{m}(*args, &block)
                assertion_delegator.send :#{m}, *args, &block
              end
            CODE
          end
        end
      end

      class AssertionDelegator
        include Test::Unit::Assertions
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
end
