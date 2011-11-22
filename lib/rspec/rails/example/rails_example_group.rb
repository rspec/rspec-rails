# Temporary workaround to resolve circular dependency between rspec-rails' spec
# suite and ammeter.
require 'rspec/rails/matchers'

module RSpec
  module Rails
    module RailsExampleGroup
      extend ActiveSupport::Concern
      include RSpec::Rails::SetupAndTeardownAdapter
      include RSpec::Rails::TestUnitAssertionAdapter
      include RSpec::Rails::Matchers
    end
  end
end
