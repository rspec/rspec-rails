# Generators are not automatically loaded by Rails
require 'generators/rspec/mailbox/mailbox_generator'
require 'support/generators'

RSpec.describe Rspec::Generators::MailboxGenerator, type: :generator, skip: !RSpec::Rails::FeatureCheck.has_action_mailbox? do
  setup_default_destination

  describe 'the generated files' do
    before { run_generator %w[forwards] }

    subject(:mailbox_spec) { file('spec/mailboxes/forwards_mailbox_spec.rb') }

    it 'generates the file' do
      expect(
        mailbox_spec
      ).to contain(/require 'rails_helper'/).and contain(/describe ForwardsMailbox, #{type_metatag(:mailbox)}/)
    end
  end
end
