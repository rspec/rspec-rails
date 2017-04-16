module RSpec
  module Rails
    # @private
    module FixtureSupport
      if defined?(ActiveRecord::TestFixtures)
        extend ActiveSupport::Concern
        include RSpec::Rails::SetupAndTeardownAdapter
        include RSpec::Rails::MinitestLifecycleAdapter if ::ActiveRecord::VERSION::STRING > '4'
        include RSpec::Rails::MinitestAssertionAdapter
        include ActiveRecord::TestFixtures

        included do
          self.fixture_path = RSpec.configuration.fixture_path
          if ::Rails::VERSION::STRING > '5'
            self.use_transactional_tests = RSpec.configuration.use_transactional_fixtures
          else
            self.use_transactional_fixtures = RSpec.configuration.use_transactional_fixtures
          end
          self.use_instantiated_fixtures  = RSpec.configuration.use_instantiated_fixtures

          def self.fixtures(*args)
            orig_methods = private_instance_methods
            super.tap do
              new_methods = private_instance_methods - orig_methods
              new_methods.each do |method_name|
                proxy_method_warning_if_called_in_before_context_scope(method_name)
              end
            end
          end

          def self.proxy_method_warning_if_called_in_before_context_scope(method_name)
            orig_implementation = instance_method(method_name)
            define_method(method_name) do |*args, &blk|
              if inspect.include?("before(:context)")
                RSpec.warn_with("Calling fixture method in before :context ")
              else
                orig_implementation.bind(self).call(*args, &blk)
              end
            end
          end

          fixtures RSpec.configuration.global_fixtures if RSpec.configuration.global_fixtures
        end
      end
    end
  end
end
