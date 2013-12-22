begin
  require 'capybara/rspec'
rescue LoadError
end

begin
  require 'capybara/rails'
rescue LoadError
end

if defined?(Capybara)
  module RSpec::Rails::CapybaraDSLDeprecated
    ::Capybara::DSL.instance_methods(false).each do |method|
      # capybara internally calls `page`, skip to avoid a duplicate
      # deprecation warning
      next if method.to_s == 'page'

      define_method method do |*args, &blk|
        RSpec.deprecate "Using the capybara method `#{method}` in controller specs",
          :replacement => "feature specs (spec/features)"
        super(*args, &blk)
      end
    end
  end

  RSpec.configure do |c|
    if defined?(Capybara::DSL)
      c.include Capybara::DSL, :type => :controller
      c.include ::RSpec::Rails::CapybaraDSLDeprecated, :type => :controller

      c.include Capybara::DSL, :type => :feature
    end

    if defined?(Capybara::RSpecMatchers)
      c.include Capybara::RSpecMatchers, :type => :view
      c.include Capybara::RSpecMatchers, :type => :helper
      c.include Capybara::RSpecMatchers, :type => :mailer
      c.include Capybara::RSpecMatchers, :type => :controller
      c.include Capybara::RSpecMatchers, :type => :feature
    end

    unless defined?(Capybara::RSpecMatchers) || defined?(Capybara::DSL)
      c.include Capybara, :type => :request
      c.include Capybara, :type => :controller
    end
  end
end
