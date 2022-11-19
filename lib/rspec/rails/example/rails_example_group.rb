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
      include RSpec::Rails::MinitestAssertionAdapter if defined?(::RSpec::Core::MinitestAssertionsAdapter)
      include RSpec::Rails::FixtureSupport
      include RSpec::Rails::TaggedLoggingAdapter if ::Rails::VERSION::MAJOR >= 7
    end
  end
end
