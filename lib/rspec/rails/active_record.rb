module RSpec
  module Rails
    # Fake class to document RSpec ActiveRecord configuration options. In practice,
    # these are dynamically added to the normal RSpec configuration object.
    class ActiveRecordConfiguration
      # @private
      def self.initialize_activerecord_configuration(_config)
        # This allows dynamic columns etc to be used on ActiveRecord models when creating instance_doubles.
        #
        # The callback is registered directly (not wrapped in `before :suite`)
        # so it takes effect as soon as rspec-rails is required, even if that
        # happens after `before :suite` has already fired in the current
        # process. This matters for runners that interleave file loading and
        # example execution per worker (e.g. test-queue), where the worker may
        # require rails_helper — and thus rspec-rails — only after entering
        # its `with_suite_hooks` block. With the previous before-suite
        # wrapper, the registration in such workers would be queued for a
        # before-suite firing that never happens, leaving instance_double
        # checks unverified for AR-backed dynamic methods.
        return unless defined?(::RSpec::Mocks) && ::RSpec::Mocks.respond_to?(:configuration)

        ::RSpec::Mocks.configuration.when_declaring_verifying_double do |possible_model|
          next unless defined?(ActiveRecord) && defined?(ActiveRecord::Base)

          target = possible_model.target

          if Class === target && ActiveRecord::Base > target && !target.abstract_class?
            target.define_attribute_methods
          end
        end
      end

      initialize_activerecord_configuration RSpec.configuration
    end
  end
end
