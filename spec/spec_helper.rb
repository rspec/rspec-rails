require 'rails/all'

module RSpecRails
  class Application < ::Rails::Application
  end
end

require 'rspec/rails'
require 'ammeter/init'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

class RSpec::Core::ExampleGroup
  def self.run_all(reporter=nil)
    run(reporter || RSpec::Mocks::Mock.new('reporter').as_null_object)
  end
end

RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus
  if RSpec::Rails.at_least_rails_3_1?
    config.filter_run_excluding :not_at_least_rails_3_1
    config.around(:each, :at_least_rails_3_1) do |example|
      orig_application = RSpec.configuration.application
      RSpec.configuration.application = RSpec::EngineExample
      example.run
      RSpec.configuration.application = orig_application
    end
  else
    config.filter_run_excluding :at_least_rails_3_1
  end
  config.run_all_when_everything_filtered = true
  config.before(:each) do
    @real_world = RSpec.world
    RSpec.instance_variable_set(:@world, RSpec::Core::World.new)
  end
  config.after(:each) do
    RSpec.instance_variable_set(:@world, @real_world)
  end
  config.order = :random
end
