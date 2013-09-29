# Temporary workaround to resolve circular dependency between rspec-rails' spec
# suite and ammeter.
require 'rspec/rails/matchers'

module RSpec
  module Rails
    module RailsExampleGroup
      extend ActiveSupport::Concern
      include RSpec::Rails::SetupAndTeardownAdapter
      include RSpec::Rails::MinitestLifecycleAdapter if ::Rails::VERSION::STRING >= '4'
      include RSpec::Rails::MinitestAssertionAdapter
      include RSpec::Rails::Matchers

      def set_metadata_type(type)
        metadata[:type] = type
        hooks.register_globals(self, RSpec.configuration.hooks)
      end

    end
  end
end
