require 'rspec/core'
require 'rspec/collection_matchers'

RSpec::configure do |c|
  c.backtrace_exclusion_patterns << /vendor\//
  c.backtrace_exclusion_patterns << /lib\/rspec\/rails/
end

require 'rails/version'
require 'rspec/rails/extensions'
require 'rspec/rails/view_rendering'
require 'rspec/rails/adapters'
require 'rspec/rails/matchers'
require 'rspec/rails/fixture_support'
require 'rspec/rails/mocks'
require 'rspec/rails/example'
require 'rspec/rails/vendor/capybara'
