# Temporary workaround to resolve circular dependency between rspec-rails' spec
# suite and ammeter.
require 'rspec/rails/matchers'

module RSpec
  module Rails
    # Common rails example functionality.
    module RailsExampleGroup
      extend ActiveSupport::Concern
      include RSpec::Rails::SetupAndTeardownAdapter
      include RSpec::Rails::MinitestLifecycleAdapter if ::Rails::VERSION::STRING >= '4'
      include RSpec::Rails::MinitestAssertionAdapter
      include RSpec::Rails::Matchers
      include RSpec::Rails::FixtureSupport if RSpec::Rails::FixtureSupport rescue false 
    end
  end
end
