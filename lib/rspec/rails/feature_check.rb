module RSpec
  module Rails
    # @private
    module FeatureCheck
      module_function
      def has_active_job?
        defined?(::ActiveJob)
      end

      def has_active_record?
        defined?(::ActiveRecord)
      end

      def has_active_record_migration?
        has_active_record? && defined?(::ActiveRecord::Migration)
      end

      def has_action_mailer?
        defined?(::ActionMailer)
      end

      def has_action_mailer_preview?
        has_action_mailer? && defined?(::ActionMailer::Preview)
      end

      def has_action_cable_testing?
        defined?(::ActionCable) && ActionCable::VERSION::MAJOR >= 6
      end

      def has_action_mailer_parameterized?
        has_action_mailer? && defined?(::ActionMailer::Parameterized::DeliveryJob)
      end

      def has_action_mailer_unified_delivery?
        has_action_mailer? && defined?(::ActionMailer::MailDeliveryJob)
      end

      def has_action_mailer_legacy_delivery_job?
        defined?(ActionMailer::DeliveryJob)
      end

      def has_action_mailbox?
        defined?(::ActionMailbox)
      end

      # TODO: add a self-explanatory method name. See https://github.com/rspec/rspec-rails/pull/2552#issuecomment-1009508693 for hints
      def rails_6_1_and_ruby_3_1?
        return false if RUBY_VERSION < "3.1"

        ::Rails::VERSION::STRING >= "6.1" && ::Rails::VERSION::STRING < "7"
      end

      def type_metatag(type)
        "type: :#{type}"
      end
    end
  end
end
