begin
  require 'capybara/rspec'
rescue LoadError
end

begin
  require 'capybara/rails'
rescue LoadError
end

if defined?(Capybara)
  RSpec.configure do |c|
    # 'capybara/rspec' defines configurations below.
    #
    # config.include Capybara::DSL, type: :feature
    # config.include Capybara::RSpecMatchers, type: :feature
    # config.include Capybara::DSL, type: :system
    # config.include Capybara::RSpecMatchers, type: :system
    # config.include Capybara::RSpecMatchers, type: :view

    if defined?(Capybara::RSpecMatchers)
      c.include Capybara::RSpecMatchers, type: :helper
      c.include Capybara::RSpecMatchers, type: :mailer
      c.include Capybara::RSpecMatchers, type: :controller
    end

    unless defined?(Capybara::RSpecMatchers) || defined?(Capybara::DSL)
      c.include Capybara, type: :request
      c.include Capybara, type: :controller
    end
  end
end
