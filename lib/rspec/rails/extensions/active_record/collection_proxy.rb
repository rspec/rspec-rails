RSpec.configure do |config|
  config.expect_with :rspec do |c|
    c.add_should_and_should_not_to ActiveRecord::Associations::CollectionProxy
  end
end
