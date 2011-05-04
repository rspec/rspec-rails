require 'rspec/core'

RSpec::configure do |c|
  c.backtrace_clean_patterns << /vendor\//
  c.backtrace_clean_patterns << /lib\/rspec\/rails/
end

require 'rspec/rails/extensions'
require 'rspec/rails/view_rendering'
require 'rspec/rails/adapters'
require 'rspec/rails/matchers'
require 'rspec/rails/fixture_support'
require 'rspec/rails/mocks'
require 'rspec/rails/module_inclusion'
require 'rspec/rails/browser_simulators'
require 'rspec/rails/example'

begin
  require 'capybara/rspec'
rescue LoadError
end

begin
  require 'capybara/rails'
rescue LoadError
end

RSpec.configure do |c|
  if defined?(Capybara::RSpecMatchers)
    c.include Capybara::RSpecMatchers, :type => :view
    c.include Capybara::RSpecMatchers, :type => :helper
    c.include Capybara::RSpecMatchers, :type => :mailer
    c.include Capybara::RSpecMatchers, :type => :controller
  end

  if defined?(Capybara::DSL)
    c.include Capybara::DSL, :type => :controller
  end

  unless defined?(Capybara::RSpecMatchers) || defined?(Capybara::DSL)
    if defined?(Capybara)
      c.include Capybara, :type => :request
      c.include Capybara, :type => :controller
    end
  end
end
