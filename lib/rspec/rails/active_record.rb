module RSpec
  module Rails
    # Fake class to document RSpec ActiveRecord configuration options. In practice,
    # these are dynamically added to the normal RSpec configuration object.
    class ActiveRecordConfiguration
      # @private
      def self.initialize_activerecord_configuration(config)
        config.before :suite do
          # This allows dynamic columns etc to be used on ActiveRecord models when creating instance_doubles
          if defined?(ActiveRecord) && defined?(::RSpec::Mocks)
            ::RSpec::Mocks.configuration.when_declaring_verifying_double do |possible_model|
              possible_model.target.define_attribute_methods if possible_model.target.respond_to?(:define_attribute_methods)
            end
          end
        end
      end

      initialize_activerecord_configuration RSpec.configuration
    end
  end
end
