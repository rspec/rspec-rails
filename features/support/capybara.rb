Around "@capybara" do |scenario, block|
  require 'capybara'
  block.call
end
