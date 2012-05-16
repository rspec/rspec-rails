if Gem::Version.new(Rails.version) >= Gem::Version.new('3.1.0')
  module RSpec
    module Rails
      module EngineSupport
        RSpec::configure do |config|
          config.add_setting :application, :default => ::Rails.application
        end
      end
    end
  end
end
