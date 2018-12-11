require "spec_helper"
require "rspec/rails/feature_check"

if RSpec::Rails::FeatureCheck.has_active_job?
  require "action_mailer"
  require "rspec/rails/matchers/have_enqueued_mail"

  class TestMailer < ActionMailer::Base
    def test_email; end
    def email_with_args(arg1, arg2); end
  end
end

RSpec.describe "HaveEnqueuedMail matchers", skip: !RSpec::Rails::FeatureCheck.has_active_job? do
  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe "have_enqueued_mail" do
    it "passes when a mailer method is called with deliver_later" do
      expect {
        TestMailer.test_email.deliver_later
      }.to have_enqueued_mail(TestMailer, :test_email)
    end
  end
end
