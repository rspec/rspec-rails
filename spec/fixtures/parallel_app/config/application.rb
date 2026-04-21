require_relative "boot"

require "rails"
require "active_record/railtie"

Bundler.require(*Rails.groups)

module ParallelApp
  class Application < Rails::Application
    config.load_defaults Rails::VERSION::STRING.to_f
    config.eager_load = false
    config.secret_key_base = "parallel-app-test-secret"
    config.logger = ActiveSupport::Logger.new(File.expand_path("../log/test.log", __dir__))
  end
end
