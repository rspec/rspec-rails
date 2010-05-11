require 'bundler'
Bundler.setup

require 'rspec/rails'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}

# TODO - most of this is borrowed from rspec-core's spec_helper - should
# be extracted to something we can use here
def in_editor?
  ENV.has_key?('TM_MODE') || ENV.has_key?('EMACS') || ENV.has_key?('VIM')
end

class Rspec::Core::ExampleGroup
  def self.run_all(reporter=nil)
    run(reporter || Rspec::Mocks::Mock.new('reporter').as_null_object)
  end
end

Rspec.configure do |c|
  c.color_enabled = !in_editor?
  c.before(:each) do
    @real_world = Rspec.world
    Rspec.instance_variable_set(:@world, Rspec::Core::World.new)
  end
  c.after(:each) do
    Rspec.instance_variable_set(:@world, @real_world)
  end
end
