require 'rspec/core'

module RSpec
  module Rails
    def self.at_least_rails_3_1?
      Gem::Version.new(::Rails.version) >= Gem::Version.new('3.1.0')
    end
  end
end

RSpec.configure do |config|
  config.backtrace_clean_patterns << /vendor\//
  config.backtrace_clean_patterns << /lib\/rspec\/rails/
  config.add_setting :application, :default => ::Rails.application

  unless RSpec::Rails.at_least_rails_3_1?
    def config.application=(*)
      raise 'Setting the application is only supported on Rails 3.1 and above.'
    end
  end
end

require 'rspec/rails/extensions'
require 'rspec/rails/view_rendering'
require 'rspec/rails/adapters'
require 'rspec/rails/matchers'
require 'rspec/rails/fixture_support'
require 'rspec/rails/mocks'
require 'rspec/rails/module_inclusion'
require 'rspec/rails/example'
require 'rspec/rails/vendor/capybara'
require 'rspec/rails/vendor/webrat'