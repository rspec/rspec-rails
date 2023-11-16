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

      included do |_other|
        around do |example|
          use_exectuor =
            case ::Rails.configuration.active_support.executor_around_test_case
            when nil then ::Rails::VERSION::MAJOR >= 7
            when true then true
            when false then false
            end

          if use_exectuor
            ::Rails.application.executor.perform { example.call }
          else
            example.call
          end
        end
      end
    end
  end
end
