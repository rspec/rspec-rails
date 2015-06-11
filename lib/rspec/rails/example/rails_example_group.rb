# Temporary workaround to resolve circular dependency between rspec-rails' spec
# suite and ammeter.
require 'rspec/rails/matchers'

module RSpec
  module Rails
    # private
    module Adapters
      # private
      module NoMinitestLifecycle
      end

      # private
      SetupAndTeardown  = RSpec::Rails::SetupAndTeardownAdapter

      # private
      MinitestAssertion = RSpec::Rails::MinitestAssertionAdapter

      # private
      MinitestLifecycle = if ::Rails::VERSION::STRING >= '4'
                            RSpec::Rails::MinitestLifecycleAdapter
                          else
                            NoMinitestLifecycle
                          end
    end

    # Common rails example functionality.
    module RailsExampleGroup
      extend ActiveSupport::Concern
      include RSpec::Rails::Adapters::SetupAndTeardown
      include RSpec::Rails::Adapters::MinitestLifecycle
      include RSpec::Rails::Adapters::MinitestAssertion
      include RSpec::Rails::Matchers
      include RSpec::Rails::FixtureSupport
    end
  end
end
