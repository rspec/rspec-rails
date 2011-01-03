if defined?(ActionMailer)
  module RSpec::Rails
    module MailerExampleGroup
      extend ActiveSupport::Concern
      include RSpec::Rails::RailsExampleGroup
      include ActionMailer::TestCase::Behavior
      include RSpec::Rails::BrowserSimulators

      webrat do
        include Webrat::Matchers
      end

      capybara do
        include Capybara
      end

      included do
        metadata[:type] = :mailer
        include ::Rails.application.routes.url_helpers
        options = ::Rails.configuration.action_mailer.default_url_options
        options.each { |key, value| default_url_options[key] = value } if options
      end

      module ClassMethods
        def mailer_class
          describes
        end
      end
    end
  end
end
