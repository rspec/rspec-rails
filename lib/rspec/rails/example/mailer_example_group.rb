require 'webrat'

module RSpec::Rails
  module MailerExampleGroup
    extend ActiveSupport::Concern

    include ActionMailer::TestCase::Behavior

    include Webrat::Matchers
    include RSpec::Matchers

    module ClassMethods
      def mailer_class
        describes
      end
    end

    RSpec.configure do |c|
      c.include self, :example_group => { :file_path => /\bspec\/mailers\// }
    end
  end
end
