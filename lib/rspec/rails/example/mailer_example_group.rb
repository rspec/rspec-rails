require 'action_mailer'
require 'webrat'

module RSpec::Rails
  module MailerExampleGroup
    extend ActiveSupport::Concern
    extend RSpec::Rails::ModuleInclusion

    include ActionMailer::TestCase::Behavior
    include Webrat::Matchers
    include RSpec::Matchers

    module ClassMethods
      def mailer_class
        describes
      end
    end

    RSpec.configure &include_self_when_dir_matches('spec','mailers')
  end
end
