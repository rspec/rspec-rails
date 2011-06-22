[
  'capybara/dsl',
  'capybara/rspec/matchers',
  'capybara/rspec/features',
  'capybara/rails'
].each do |dependency|
  begin
    require dependency
  rescue LoadError
  end
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
