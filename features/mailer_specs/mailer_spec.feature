Feature: mailer spec

  @rails_post_5
  Scenario: simple passing example
    Given a file named "spec/mailers/notifications_mailer_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe NotificationsMailer, :type => :mailer do
        describe "notify" do
          let(:mail) { NotificationsMailer.signup }

          it "renders the headers" do
            expect(mail.subject).to eq("Signup")
            expect(mail.to).to eq(["to@example.org"])
            expect(mail.from).to eq(["from@example.com"])
          end

          it "renders the body" do
            expect(mail.body.encoded).to match("Hi")
          end
        end
      end
      """
    When I run `rspec spec`
    Then the example should pass

  @rails_pre_5
  Scenario: using URL helpers without default options
    Given a file named "config/initializers/mailer_defaults.rb" with:
      """ruby
      # no default options
      """
    And a file named "spec/mailers/notifications_spec.rb" with:
      """ruby
      require 'rails_helper'

      RSpec.describe Notifications, :type => :mailer do
        let(:mail) { Notifications.signup }

        it "renders the headers" do
          expect(mail.subject).to eq("Signup")
          expect(mail.to).to eq(["to@example.org"])
          expect(mail.from).to eq(["from@example.com"])
        end

        it 'renders the body' do
          expect(mail.body.encoded).to match("Hi")
        end
      end
      """
    When I run `rspec spec`
    Then the examples should all pass
