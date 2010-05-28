require 'rspec/core'
require 'rspec/rails/monkey'
require 'rspec/rails/extensions'
require 'rspec/rails/null_resolver'
require 'rspec/rails/view_rendering'
require 'rspec/rails/adapters'
require 'rspec/core'
require 'rspec/rails/matchers'
require 'rspec/rails/example'
require 'rspec/rails/mocks'
require 'rspec/rails/configuration'

RSpec.configure do |c|
  c.add_option :use_transactional_examples, :type => :boolean, :default => true
  c.add_option :use_transactional_fixtures, :type => :boolean, :default => true 
  c.add_option :use_instantiated_fixtures,  :type => :boolean, :default => false

  (class << c ; self ; end ).class_eval do 
    include RSpec::Rails::Configuration
  end
  
end
