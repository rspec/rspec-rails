require 'rails/all'

module RSpecRails
  class Application < ::Rails::Application
    config.secret_key_base = 'ASecretString'

    if defined?(ActionCable)
      ActionCable.server.config.cable = {"adapter" => "test"}
      ActionCable.server.config.logger =
        ActiveSupport::TaggedLogging.new ActiveSupport::Logger.new(StringIO.new)
    end
  end
end

I18n.enforce_available_locales = true

require 'rspec/support/spec'
require 'rspec/rails'
require 'ammeter/init'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each { |f| require f }

class RSpec::Core::ExampleGroup
  def self.run_all(reporter = nil)
    run(reporter || RSpec::Mocks::Mock.new('reporter').as_null_object)
  end
end

# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.expect_with :rspec do |expectations|
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    mocks.verify_partial_doubles = true
    mocks.verify_doubled_constant_names = true
  end

  config.expect_with :rspec do |c|
    c.max_formatted_output_length = 1000
  end

  config.filter_run :focus
  config.run_all_when_everything_filtered = true

  config.order = :random
  Kernel.srand config.seed

  config.shared_context_metadata_behavior = :apply_to_host_groups

  config.disable_monkey_patching!

  config.warnings = true
  config.raise_on_warning = true

  config.around(:example) do |example|
    real_world = RSpec.world
    RSpec.instance_variable_set(:@world, RSpec::Core::World.new)
    example.run
    RSpec.instance_variable_set(:@world, real_world)
  end
end
