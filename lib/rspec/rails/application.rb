module RSpec
  module Rails
    module Application
      RSpec.configuration.add_setting :application, :default => ::Rails.application

      # unless at_least_rails_3_1?
      #   # def RSpec.configuration.application=(*)
      #   #   raise "Setting the application is only supported on Rails 3.1 and above."
      #   # end
      # end
    end
  end
end
