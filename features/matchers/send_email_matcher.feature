Feature: `send_email` matcher

  The `send_email` matcher is used to check if an email with the given parameters has been sent inside the expectation block.

  NOTE: This matcher implies that the example(s) actually send email(s) using the test adapter, and *not* scheduled as a job to be sent in the background later.

  To have an email sent in tests make sure:
  - `ActionMailer` performs deliveries - `Rails.application.config.action_mailer.perform_deliveries = true`
  - If the email is sent asynchronously (with `.deliver_later` call), ActiveJob uses the inline adapter - `Rails.application.config.active_job.queue_adapter = :inline`
  - ActionMailer uses the test adapter - `Rails.application.config.action_mailer.delivery_method = :test`

  If you want to check an email has been scheduled as a job, use the `have_enqueued_email` matcher.

  Scenario: Checking email sent with the given multiple parameters
    Given a file named "spec/mailers/notifications_mailer_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe NotificationsMailer , type: :mailer do
        it "checks email sending by multiple params" do
          expect {
            NotificationsMailer.signup.deliver_now
          }.to send_email(
            from: 'from@example.com',
            to: 'to@example.org',
            subject: 'Signup'
          )
        end
      end
      """
    When I run `rspec spec/mailers/notifications_mailer_spec.rb`
    Then the examples should all pass

  Scenario: Checking email sent with matching parameters
    Given a file named "spec/mailers/notifications_mailer_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe NotificationsMailer , type: :mailer do
        it "checks email sending by one param only" do
          expect {
            NotificationsMailer.signup.deliver_now
          }.to send_email(
            to: 'to@example.org'
          )
        end
      end
      """
    When I run `rspec spec/mailers/notifications_mailer_spec.rb`
    Then the examples should all pass

  Scenario: Checking email not sent with the given parameters
    Given a file named "spec/mailers/notifications_mailer_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe NotificationsMailer , type: :mailer do
        it "checks email not sent" do
          expect {
            NotificationsMailer.signup.deliver_now
          }.to_not send_email(
            to: 'no@example.org'
          )
        end
      end
      """
    When I run `rspec spec/mailers/notifications_mailer_spec.rb`
    Then the examples should all pass
