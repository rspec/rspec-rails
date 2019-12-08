require 'rails/all'

module RSpecRails
  class Application < ::Rails::Application
    self.config.secret_key_base = 'ASecretString'

    if defined?(ActionCable)
      ActionCable.server.config.cable = { "adapter" => "test" }
      ActionCable.server.config.logger =
        ActiveSupport::TaggedLogging.new ActiveSupport::Logger.new(StringIO.new)
    end
  end
end
I18n.enforce_available_locales = true if I18n.respond_to?(:enforce_available_locales)

require 'rspec/support/spec'
require 'rspec/rails'
require 'ammeter/init'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

class RSpec::Core::ExampleGroup
  def self.run_all(reporter=nil)
    run(reporter || RSpec::Mocks::Mock.new('reporter').as_null_object)
  end
end

RSpec.configure do |config|
  config.filter_run :focus
  config.run_all_when_everything_filtered = true
  config.order = :random

  real_world = nil
  config.before(:each) do
    real_world = RSpec.world
    RSpec.instance_variable_set(:@world, RSpec::Core::World.new)
  end
  config.after(:each) do
    RSpec.instance_variable_set(:@world, real_world)
  end
end
