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
          self.use_transactional_fixtures = RSpec.configuration.use_transactional_fixtures
          self.use_instantiated_fixtures  = RSpec.configuration.use_instantiated_fixtures
          fixtures RSpec.configuration.global_fixtures if RSpec.configuration.global_fixtures
        end
      end
    end
  end
end
