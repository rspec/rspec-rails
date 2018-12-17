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

    it "passes when using the have_enqueued_email alias" do
      expect {
        TestMailer.test_email.deliver_later
      }.to have_enqueued_email(TestMailer, :test_email)
    end

    it "passes when using the enqueue_mail alias" do
      expect {
        TestMailer.test_email.deliver_later
      }.to enqueue_mail(TestMailer, :test_email)
    end

    it "passes when using the enqueue_email alias" do
      expect {
        TestMailer.test_email.deliver_later
      }.to enqueue_email(TestMailer, :test_email)
    end

    it "passes when negated" do
      expect { }.not_to have_enqueued_email(TestMailer, :test_email)
    end

    # it "counts only emails enqueued in the block" do
      # TestMailer.test_email

      # expect {
        # TestMailer.test_email
      # }.to have_enqueued_email(TestMailer, :test_email).once
    # end

    it "passes with provided argument matchers" do
      expect {
        TestMailer.email_with_args(1, 2).deliver_later
      }.to have_enqueued_mail(TestMailer, :email_with_args).with(1, 2)

      expect {
        TestMailer.email_with_args(1, 2).deliver_later
      }.not_to have_enqueued_mail(TestMailer, :email_with_args).with(3, 4)
    end

    it "generates a failure message" do
      expect {
        expect { }.to have_enqueued_email(TestMailer, :test_email)
      }.to raise_error(/expected to enqueue TestMailer.test_email/)
    end

    it "generates a failure message with arguments" do
      expect {
        expect { }.to have_enqueued_email(TestMailer, :email_with_args).with(1, 2)
      }.to raise_error(/expected to enqueue TestMailer.email_with_args with \[1, 2\]/)
    end

    it "throws descriptive error when no test adapter set" do
      queue_adapter = ActiveJob::Base.queue_adapter
      ActiveJob::Base.queue_adapter = :inline

      expect {
        expect { TestMailer.test_email }.to have_enqueued_mail(TestMailer, :test_email)
      }.to raise_error("To use ActiveJob matchers set `ActiveJob::Base.queue_adapter = :test`")

      ActiveJob::Base.queue_adapter = queue_adapter
    end
  end
end
