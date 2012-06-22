require 'rspec-rails'
module RSpec
  module Rails
    module Application
      RSpec.configuration.add_setting :application, :default => ::Rails.application

      # Raise an error when setting application in Rails < 3.1
      unless RSpec::Rails.at_least_rails_3_1?
        class << RSpec.configuration
          def application=(*)
            raise "Setting the application is only supported on Rails 3.1 and above."
          end
        end
      end

    end
  end
end
