# Temporary workaround to resolve circular dependency between rspec-rails' spec
# suite and ammeter.
require 'rspec/rails/matchers'
require 'rspec/rails/rails_version'

module RSpec
  module Rails
    module RailsExampleGroup
      extend ActiveSupport::Concern
      include RSpec::Rails::SetupAndTeardownAdapter
      include RSpec::Rails::MiniTestLifecycleAdapter if RSpec::Rails.rails_version_satisfied_by?('>= 4.0.0.beta1')
      include RSpec::Rails::TestUnitAssertionAdapter
      include RSpec::Rails::Matchers
    end
  end
end
