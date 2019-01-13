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

RSpec.describe "HaveEnqueuedMail matchers", :skip => !RSpec::Rails::FeatureCheck.has_active_job? do
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

    it 'fails when negated and mail is enqueued' do
      expect {
        expect {
          TestMailer.test_email.deliver_later
        }.not_to have_enqueued_mail(TestMailer, :test_email)
      }.to raise_error(/expected not to enqueue TestMailer.test_email exactly 1 time but enqueued 1/)
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

    it "passes with at_least when enqueued emails are over the limit" do
      expect {
        TestMailer.test_email.deliver_later
        TestMailer.test_email.deliver_later
      }.to have_enqueued_mail(TestMailer, :test_email).at_least(:once)
    end

    it "passes with at_most when enqueued emails are under the limit" do
      expect {
        TestMailer.test_email.deliver_later
      }.to have_enqueued_mail(TestMailer, :test_email).at_most(:twice)
    end

    it "generates a failure message with at least hint" do
      expect {
        expect { }.to have_enqueued_mail(TestMailer, :test_email).at_least(:once)
      }.to raise_error(/expected to enqueue TestMailer.test_email at least 1 time but enqueued 0/)
    end

    it "generates a failure message with at most hint" do
      expect {
        expect {
          TestMailer.test_email.deliver_later
          TestMailer.test_email.deliver_later
        }.to have_enqueued_mail(TestMailer, :test_email).at_most(:once)
      }.to raise_error(/expected to enqueue TestMailer.test_email at most 1 time but enqueued 2/)
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
      }.to raise_error(/expected to enqueue TestMailer.email_with_args exactly 1 time with \[1, 2\], but enqueued 0/)
    end

    it "passes when deliver_later is called with a wait_until argument" do
      send_time = Date.tomorrow.noon

      expect {
        TestMailer.test_email.deliver_later(:wait_until => send_time)
      }.to have_enqueued_email(TestMailer, :test_email).at(send_time)
    end

    it "generates a failure message with at" do
      send_time = Date.tomorrow.noon

      expect {
        expect {
          TestMailer.test_email.deliver_later(:wait_until => send_time + 1)
        }.to have_enqueued_email(TestMailer, :test_email).at(send_time)
      }.to raise_error(/expected to enqueue TestMailer.test_email exactly 1 time at #{send_time.strftime('%F %T')}/)
    end

    it "passes when deliver_later is called with a queue argument" do
      expect {
        TestMailer.test_email.deliver_later(:queue => 'urgent_mail')
      }.to have_enqueued_email(TestMailer, :test_email).on_queue('urgent_mail')
    end

    it "generates a failure message with on_queue" do
      expect {
        expect {
          TestMailer.test_email.deliver_later(:queue => 'not_urgent_mail')
        }.to have_enqueued_email(TestMailer, :test_email).on_queue('urgent_mail')
      }.to raise_error(/expected to enqueue TestMailer.test_email exactly 1 time on queue urgent_mail/)
    end

    it "generates a failure message with unmatching enqueued mail jobs" do
      non_mailer_job = Class.new(ActiveJob::Base) do
        def perform; end
        def self.name; "NonMailerJob"; end
      end

      send_time = Date.tomorrow.noon
      queue = 'urgent_mail'

      message = "expected to enqueue TestMailer.email_with_args exactly 1 time with [1, 2], but enqueued 0" + \
                "\nQueued deliveries:" + \
                "\n  TestMailer.test_email" + \
                "\n  TestMailer.email_with_args with [3, 4], on queue #{queue}, at #{send_time}"

      expect {
        expect {
          non_mailer_job.perform_later
          TestMailer.test_email.deliver_later
          TestMailer.email_with_args(3, 4).deliver_later(:wait_until => send_time, :queue => queue)
        }.to have_enqueued_email(TestMailer, :email_with_args).with(1, 2)
      }.to raise_error(message)
    end

    it "throws descriptive error when no test adapter set" do
      queue_adapter = ActiveJob::Base.queue_adapter
      ActiveJob::Base.queue_adapter = :inline

      expect {
        expect { TestMailer.test_email.deliver_later }.to have_enqueued_mail(TestMailer, :test_email)
      }.to raise_error("To use HaveEnqueuedMail matcher set `ActiveJob::Base.queue_adapter = :test`")

      ActiveJob::Base.queue_adapter = queue_adapter
    end

    it "fails with with block with incorrect data" do
      expect {
        expect {
          TestMailer.email_with_args('asdf', 'zxcv').deliver_later
        }.to have_enqueued_mail(TestMailer, :email_with_args).with { |first_arg, second_arg|
          expect(first_arg).to eq("zxcv")
        }
      }.to raise_error { |e|
        expect(e.message).to match(/expected: "zxcv"/)
        expect(e.message).to match(/got: "asdf"/)
      }
    end

    it "passes multiple arguments to with block" do
      expect {
        TestMailer.email_with_args('asdf', 'zxcv').deliver_later
      }.to have_enqueued_mail(TestMailer, :email_with_args).with { |first_arg, second_arg|
        expect(first_arg).to eq("asdf")
        expect(second_arg).to eq("zxcv")
      }
    end

    it "only calls with block if other conditions are met" do
      noon = Date.tomorrow.noon
      midnight = Date.tomorrow.midnight

      expect {
        TestMailer.email_with_args('high', 'noon').deliver_later(:wait_until => noon)
        TestMailer.email_with_args('midnight', 'rider').deliver_later(:wait_until => midnight)
      }.to have_enqueued_mail(TestMailer, :email_with_args).at(noon).with { |first_arg, second_arg|
        expect(first_arg).to eq('high')
        expect(second_arg).to eq('noon')
      }
    end
  end
end
