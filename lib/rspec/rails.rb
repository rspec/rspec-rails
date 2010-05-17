require 'rspec/rails/monkey'
require 'rspec/rails/extensions'
require 'rspec/rails/null_resolver'
require 'rspec/rails/view_rendering'
require 'rspec/rails/adapters'
require 'rspec/rails/transactional_database_support'
require 'rspec/rails/matchers'
require 'rspec/rails/example'
require 'rspec/rails/mocks'

RSpec.configure do |c|
  c.add_option :use_transactional_examples, :type => :boolean, :default => true
end
