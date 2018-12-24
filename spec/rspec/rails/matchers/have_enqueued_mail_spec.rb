require "spec_helper"
require "rspec/rails/feature_check"

if RSpec::Rails::FeatureCheck.has_active_job?
  require "action_mailer"
  require "rspec/rails/matchers/have_enqueued_mail"

  class TestMailer < ActionMailer::Base
    def test_email; end
    def email_with_args(arg1, arg2); end
    def email_with_optional_args(required_arg, optional_arg = nil); end
  end
end

RSpec.describe "HaveEnqueuedMail matchers", skip: !RSpec::Rails::FeatureCheck.has_active_job? do
  before do
    ActiveJob::Base.queue_adapter = :test
  end

  around do |example|
    original_logger = ActiveJob::Base.logger
    ActiveJob::Base.logger = Logger.new(nil) # Silence messages "[ActiveJob] Enqueued ...".
    example.run
    ActiveJob::Base.logger = original_logger
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
      expect { }.not_to have_enqueued_mail(TestMailer, :test_email)
    end

    it "counts only emails enqueued in the block" do
      TestMailer.test_email.deliver_later

      expect {
        TestMailer.test_email.deliver_later
      }.to have_enqueued_mail(TestMailer, :test_email).once
    end

    it "fails when too many emails are enqueued" do
      expect {
        expect {
          TestMailer.test_email.deliver_later
          TestMailer.test_email.deliver_later
        }.to have_enqueued_mail(TestMailer, :test_email).exactly(1)
      }.to raise_error(/expected to enqueue TestMailer.test_email exactly 1 time/)
    end

    it "passes with :once count" do
      expect {
        TestMailer.test_email.deliver_later
      }.to have_enqueued_mail(TestMailer, :test_email).once
    end

    it "passes with :twice count" do
      expect {
        TestMailer.test_email.deliver_later
        TestMailer.test_email.deliver_later
      }.to have_enqueued_mail(TestMailer, :test_email).twice
    end

    it "passes with :thrice count" do
      expect {
        TestMailer.test_email.deliver_later
        TestMailer.test_email.deliver_later
        TestMailer.test_email.deliver_later
      }.to have_enqueued_mail(TestMailer, :test_email).thrice
    end

    it "matches based on mailer class and method name" do
      expect {
        TestMailer.test_email.deliver_later
        TestMailer.email_with_args(1, 2).deliver_later
      }.to have_enqueued_mail(TestMailer, :test_email).once
    end

    it "passes with multiple emails" do
      expect {
        TestMailer.test_email.deliver_later
        TestMailer.email_with_args(1, 2).deliver_later
      }.to have_enqueued_mail(TestMailer, :test_email).and have_enqueued_mail(TestMailer, :email_with_args)
    end

    it "passes for mailer methods that accept arguments when the provided argument matcher is not used" do
      expect {
        TestMailer.email_with_args(1, 2).deliver_later
      }.to have_enqueued_mail(TestMailer, :email_with_args)
    end

    it "passes for mailer methods with default arguments" do
      expect {
        TestMailer.email_with_optional_args('required').deliver_later
      }.to have_enqueued_mail(TestMailer, :email_with_optional_args)

      expect {
        TestMailer.email_with_optional_args('required').deliver_later
      }.to have_enqueued_mail(TestMailer, :email_with_optional_args).with('required')

      expect {
        TestMailer.email_with_optional_args('required', 'optional').deliver_later
      }.to have_enqueued_mail(TestMailer, :email_with_optional_args).with('required', 'optional')
    end

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
      }.to raise_error(/expected to enqueue TestMailer.email_with_args exactly 1 time with \[1, 2\] but enqueued 0/)
    end

    it "generates a failure message with unmatching enqueued mail jobs" do
      message = "expected to enqueue TestMailer.email_with_args exactly 1 time with [1, 2] but enqueued 0" + \
                "\nQueued deliveries:" + \
                "\n  TestMailer.test_email" + \
                "\n  TestMailer.email_with_args with [3, 4]"

      expect {
        expect {
          TestMailer.test_email.deliver_later
          TestMailer.email_with_args(3, 4).deliver_later
        }.to have_enqueued_email(TestMailer, :email_with_args).with(1, 2)
      }.to raise_error(message)
    end

    it "throws descriptive error when no test adapter set" do
      queue_adapter = ActiveJob::Base.queue_adapter
      ActiveJob::Base.queue_adapter = :inline

      expect {
        expect { TestMailer.test_email.deliver_later }.to have_enqueued_mail(TestMailer, :test_email)
      }.to raise_error("To use ActiveJob matchers set `ActiveJob::Base.queue_adapter = :test`")

      ActiveJob::Base.queue_adapter = queue_adapter
    end
  end
end
