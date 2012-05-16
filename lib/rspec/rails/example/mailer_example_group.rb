if defined?(ActionMailer)
  module RSpec::Rails
    module MailerExampleGroup
      extend ActiveSupport::Concern
      include RSpec::Rails::RailsExampleGroup
      include ActionMailer::TestCase::Behavior

      included do
        metadata[:type] = :mailer
        if Gem::Version.new(Rails.version) >= Gem::Version.new('3.1.0')
          include RSpec.configuration.application.routes.url_helpers
        else
          include ::Rails.application.routes.url_helpers
        end
        options = ::Rails.configuration.action_mailer.default_url_options
        options.each { |key, value| default_url_options[key] = value } if options
      end

      module ClassMethods
        def mailer_class
          described_class
        end
      end
    end
  end
end
