require 'rspec/collection_matchers'
require 'rails/all'

module RSpecRails
  class Application < ::Rails::Application
    self.config.secret_key_base = 'ASecretString' if config.respond_to? :secret_key_base
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
  real_world = nil

  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.before(:each) do
    real_world = RSpec.world
    RSpec.instance_variable_set(:@world, RSpec::Core::World.new)
  end
  config.after(:each) do
    RSpec.instance_variable_set(:@world, real_world)
  end
  config.order = :random
end
