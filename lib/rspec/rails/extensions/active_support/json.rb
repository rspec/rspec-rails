RSpec.configure do |c|
  c.before(:suite) do
    if defined?(::RSpec::Mocks)
      # Need to require the base file to setup internal support require helpers
      require 'rspec/mocks'
      require 'rspec/mocks/test_double'
      ::RSpec::Mocks::TestDouble.module_exec do
        # @private
        def as_json(*args, &block)
          return method_missing(:as_json, *args, &block) unless null_object?
          __mock_proxy.record_message_received(:as_json, *args, &block)
          nil
        end

        # @private
        def to_json(*args, &block)
          return method_missing(:to_json, *args, &block) unless null_object?
          __mock_proxy.record_message_received(:to_json, *args, &block)
          "null"
        end

        # @private
        remove_method(:respond_to?)
        def respond_to?(message, incl_private = false)
          return true if null_object?
          if [:to_json, :as_json].include?(message)
            public_methods(false).include?(message)
          else
            super
          end
        end
      end

      require 'rspec/mocks/verifying_double'
      ::RSpec::Mocks::VerifyingDouble.module_exec do
        # @private
        def as_json(*args, &block)
          verify_on_mock_proxy(:as_json, *args)
          super
        end

        # @private
        def to_json(*args, &block)
          verify_on_mock_proxy(:to_json, *args)
          super
        end

      private

        def verify_on_mock_proxy(message, *args)
          # Null object conditional is an optimization. If not a null object,
          # validity of method expectations will have been checked at
          # definition time.
          return unless null_object?

          if @__sending_message == message
            __mock_proxy.ensure_implemented(message)
          else
            __mock_proxy.ensure_publicly_implemented(message, self)
          end

          __mock_proxy.validate_arguments!(message, args)
        end
      end
    end
  end
end
