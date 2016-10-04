# This file should only contain the bare minimum required to configure the spec suite
require 'rspec/support/spec'

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
