require 'rails/all'

module RSpecRails
  class Application < ::Rails::Application
    self.config.secret_key_base = 'ASecretString' if config.respond_to? :secret_key_base
  end
end
I18n.enforce_available_locales = true if I18n.respond_to?(:enforce_available_locales)

require 'rspec/support/spec'
require 'rspec/rails'

Dir["#{File.dirname(__FILE__)}/support/**/*.rb"].each {|f| require f}
