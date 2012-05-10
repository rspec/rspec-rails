module RSpec
  module Rails
    module EngineSupport
      RSpec::configure do |config|
        config.add_setting :application, :default => ::Rails.application
      end
    end
  end
end
