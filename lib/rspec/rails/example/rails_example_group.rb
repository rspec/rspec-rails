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

      if ::Rails::VERSION::MAJOR >= 7
        require 'active_support/testing/tagged_logging'
        include ActiveSupport::Testing::TaggedLogging
      end
    end
  end
end
