# Temporary workaround to resolve circular dependency between rspec-rails' spec
# suite and ammeter.
require 'rspec/rails/matchers'

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
      include RSpec::Rails::TaggedLoggingAdapter if ::Rails::VERSION::MAJOR >= 7

      if ::Rails::VERSION::MAJOR >= 7
        include RSpec::Rails::TaggedLoggingAdapter
        include ActiveSupport::ExecutionContext::TestHelper
        included do |_other|
          around do |example|
            if ::Rails.configuration.active_support.executor_around_test_case
              ::Rails.application.executor.perform { example.call }
            else
              example.call
            end
          end
        end
      end
    end
  end
end
