require 'active_support/concern'

module RSpec::Rails::Adapters
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
end
