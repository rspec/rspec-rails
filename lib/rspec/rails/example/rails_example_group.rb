# Temporary workaround to resolve circular dependency between rspec-rails' spec
# suite and ammeter.
require 'rspec/rails/matchers'

require 'active_support/current_attributes/test_helper'
require 'active_support/execution_context/test_helper'

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
      include RSpec::Rails::TaggedLoggingAdapter

      if RSpec::Rails::FeatureCheck.has_active_job?
        include ActiveJob::TestHelper
      end

      included do
        unless RSpec::Rails::RailsExampleGroup.executor_around_test_case?
          include ActiveSupport::CurrentAttributes::TestHelper
          include ActiveSupport::ExecutionContext::TestHelper
        end
      end

      # @private
      def self.executor_around_test_case?
        return false unless ::Rails.application

        ::Rails.application.config.active_support.executor_around_test_case ? true : false
      end
    end
  end
end
