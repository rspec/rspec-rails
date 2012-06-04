require 'rspec/core'

RSpec::configure do |c|
  c.backtrace_clean_patterns << /vendor\//
  c.backtrace_clean_patterns << /lib\/rspec\/rails/
end

def at_least_rails_3_1?
  Gem::Version.new(Rails.version) >= Gem::Version.new('3.1.0')
end

require 'rspec/rails/extensions'
require 'rspec/rails/view_rendering'
require 'rspec/rails/adapters'
require 'rspec/rails/matchers'
require 'rspec/rails/fixture_support'
require 'rspec/rails/mocks'
require 'rspec/rails/module_inclusion'
require 'rspec/rails/example'
require 'rspec/rails/vendor/capybara'
require 'rspec/rails/vendor/webrat'
require 'rspec/rails/application'
