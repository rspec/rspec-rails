begin
  require 'capybara/rspec'
rescue LoadError
end

begin
  require 'capybara/rails'
rescue LoadError
end

begin
  require 'webrat'
rescue LoadError
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

  if defined?(Webrat)
    c.include Webrat::Matchers, :type => :request
    c.include Webrat::Matchers, :type => :controller
    c.include Webrat::Matchers, :type => :view
    c.include Webrat::Matchers, :type => :helper
    c.include Webrat::Matchers, :type => :mailer

    c.include Webrat::Methods,  :type => :request
    c.include Webrat::Methods,  :type => :controller

    module RequestInstanceMethods
      def last_response
        @response
      end
    end

    c.include RequestInstanceMethods, :type => :request

    c.before :type => :controller do
      Webrat.configure {|c| c.mode = :rails}
    end

    c.before :type => :request do
      Webrat.configure {|c| c.mode = :rack}
    end
  end
end
