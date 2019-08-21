require 'generators/rspec'

module Rspec
  module Generators
    # @private
    class MailboxGenerator < Base
      def create_mailbox_spec
        template('mailbox_spec.rb.erb',
                 File.join('spec/mailboxes', class_path, "#{file_name}_mailbox_spec.rb")
        )
      end
    end
  end
end
