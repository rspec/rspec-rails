# Temporary workaround to resolve circular dependency between rspec-rails' spec
# suite and ammeter.
require 'rspec/rails/matchers'

if ::Rails::VERSION::MAJOR >= 7
  require 'active_support/current_attributes/test_helper'
  require 'active_support/execution_context/test_helper'
end

module RSpec
  module Rails
    # @api public
    # Common rails example functionality.
    module RailsExampleGroup
      extend ActiveSupport::Concern
      include RSpec::Rails::SetupAndTeardownAdapter
      include RSpec::Rails::MinitestLifecycleAdapter
      include RSpec::Rails::MinitestAssertionAdapter
      include RSpec::Rails::FixtureSupport

      if ::Rails::VERSION::MAJOR >= 7
        include RSpec::Rails::TaggedLoggingAdapter

        if ::Rails.configuration.active_support.executor_around_test_case
          included do |_other|
            around do |example|
              ::Rails.application.executor.perform { example.call }
            end
          end
        else
          include ActiveSupport::CurrentAttributes::TestHelper
          include ActiveSupport::ExecutionContext::TestHelper
        end
      end
    end
  end
end
