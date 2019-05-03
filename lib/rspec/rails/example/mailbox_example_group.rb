module RSpec
  module Rails
    # @api public
    # Container module for mailbox spec functionality.
    module MailboxExampleGroup
      extend ActiveSupport::Concern

      if RSpec::Rails::FeatureCheck.has_action_mailbox?
        require 'action_mailbox/test_helper'
        extend ::ActionMailbox::TestHelper

        def self.create_inbound_email(arg)
          case arg
          when Hash
            create_inbound_email_from_mail(arg)
          else
            create_inbound_email_from_source(arg.to_s)
          end
        end
      else
        def self.create_inbound_email(_arg)
          raise "Could not load ActionMailer::TestHelper"
        end
      end

      class_methods do
        # @private
        def mailbox_class
          described_class
        end
      end

      included do
        subject { described_class }
      end

      # Verify the status of any inbound email
      #
      # @example
      #     describe ForwardsMailbox do
      #       it "can describe what happened to the inbound email" do
      #         mail = process(args)
      #
      #         # can use any of:
      #         expect(mail).to have_been_delivered
      #         expect(mail).to have_bounced
      #         expect(mail).to have_failed
      #       end
      #     end
      def have_been_delivered
        satisfy('have been delivered', &:delivered?)
      end

      def have_bounced
        satisfy('have bounced', &:bounced?)
      end

      def have_failed
        satisfy('have failed', &:failed?)
      end

      # Process an inbound email message directly, bypassing routing.
      #
      # @param message [Hash, Mail::Message] a mail message or hash of
      #   attributes used to build one
      # @return [ActionMaibox::InboundMessage]
      def process(message)
        MailboxExampleGroup.create_inbound_email(message).tap do |mail|
          self.class.mailbox_class.receive(mail)
        end
      end
    end
  end
end
