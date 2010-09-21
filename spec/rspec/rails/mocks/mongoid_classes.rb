# Configure the MongoID database
require 'mongoid'
require 'database_cleaner'

Mongoid.configure do |config|
  name = "mongoid_rspec_test"
  config.master = Mongo::Connection.new.db(name)
end

DatabaseCleaner.orm = "mongoid"

Rspec.configure do |config|
  config.before(:all) do
    DatabaseCleaner.strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end

# Define the documents

class MongoidMockableModel
  include Mongoid::Document
  references_one :mongoid_associated_model
end

class MongoidAssociatedModel
  include Mongoid::Document
  referenced_in :mongoid_mockable_model
end