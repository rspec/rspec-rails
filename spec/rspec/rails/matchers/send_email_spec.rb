RSpec.describe "send_email" do
  let(:mailer) do
    Class.new(ActionMailer::Base) do
      self.delivery_method = :test

      def test_email
        mail(
          from: "from@example.com",
          cc: "cc@example.com",
          bcc: "bcc@example.com",
          to: "to@example.com",
          subject: "Test email",
          body: "Test email body"
        )
      end
    end
  end

  it "checks email sending by all params together" do
    expect {
      mailer.test_email.deliver_now
    }.to send_email(
      from: "from@example.com",
      to: "to@example.com",
      cc: "cc@example.com",
      bcc: "bcc@example.com",
      subject: "Test email",
      body: a_string_including("Test email body")
    )
  end

  it "checks email sending by no params" do
    expect {
      mailer.test_email.deliver_now
    }.to send_email
  end

  it "with to_not" do
    expect {
      mailer.test_email.deliver_now
    }.to_not send_email(
      from: "failed@example.com"
    )
  end

  it "fails with a clear message" do
    expect {
      expect { mailer.test_email.deliver_now }.to send_email(from: 'failed@example.com')
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError, <<~MSG.strip)
      No matching emails were sent.

      The following emails were sent:
      - subject: Test email, from: ["from@example.com"], to: ["to@example.com"], cc: ["cc@example.com"], bcc: ["bcc@example.com"]
    MSG
  end

  it "fails with a clear message when no emails were sent" do
    expect {
      expect { }.to send_email
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError, <<~MSG.strip)
      No matching emails were sent.

      There were no emails sent inside the expectation block.
    MSG
  end

  it "fails with a clear message for negated version" do
    expect {
      expect { mailer.test_email.deliver_now }.to_not send_email(from: "from@example.com")
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError, "Expected not to send an email but it was sent.")
  end

  it "fails for multiple matches" do
    expect {
      expect { 2.times { mailer.test_email.deliver_now } }.to send_email(from: "from@example.com")
    }.to raise_error(RSpec::Expectations::ExpectationNotMetError, <<~MSG.strip)
      More than 1 matching emails were sent.

      The following emails were sent:
      - subject: Test email, from: ["from@example.com"], to: ["to@example.com"], cc: ["cc@example.com"], bcc: ["bcc@example.com"]
      - subject: Test email, from: ["from@example.com"], to: ["to@example.com"], cc: ["cc@example.com"], bcc: ["bcc@example.com"]
    MSG
  end

  context "with compound matching" do
    it "works when both matchings pass" do
      expect {
        expect {
          mailer.test_email.deliver_now
        }.to send_email(to: "to@example.com").and send_email(from: "from@example.com")
      }.to_not raise_error
    end

    it "works when first matching fails" do
      expect {
        expect {
          mailer.test_email.deliver_now
        }.to send_email(to: "no@example.com").and send_email(to: "to@example.com")
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, <<~MSG.strip)
        No matching emails were sent.

        The following emails were sent:
        - subject: Test email, from: ["from@example.com"], to: ["to@example.com"], cc: ["cc@example.com"], bcc: ["bcc@example.com"]
      MSG
    end

    it "works when second matching fails" do
      expect {
        expect {
          mailer.test_email.deliver_now
        }.to send_email(to: "to@example.com").and send_email(to: "no@example.com")
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, <<~MSG.strip)
        No matching emails were sent.

        The following emails were sent:
        - subject: Test email, from: ["from@example.com"], to: ["to@example.com"], cc: ["cc@example.com"], bcc: ["bcc@example.com"]
      MSG
    end
  end

  context "with a custom negated version defined" do
    define_negated_matcher :not_send_email, :send_email

    it "works with a negated version" do
      expect {
        mailer.test_email.deliver_now
      }.to not_send_email(
        from: "failed@example.com"
      )
    end

    it "fails with a clear message" do
      expect {
        expect { mailer.test_email.deliver_now }.to not_send_email(from: "from@example.com")
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, "Expected not to send an email but it was sent.")
    end

    context "with a compound negated version" do
      it "works when both matchings pass" do
        expect {
          expect {
            mailer.test_email.deliver_now
          }.to not_send_email(to: "noto@example.com").and not_send_email(from: "nofrom@example.com")
        }.to_not raise_error
      end

      it "works when first matching fails" do
        expect {
          expect {
            mailer.test_email.deliver_now
          }.to not_send_email(to: "to@example.com").and send_email(to: "to@example.com")
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError, a_string_including(<<~MSG.strip))
          Expected not to send an email but it was sent.
        MSG
      end

      it "works when second matching fails" do
        expect {
          expect {
            mailer.test_email.deliver_now
          }.to send_email(to: "to@example.com").and not_send_email(to: "to@example.com")
        }.to raise_error(RSpec::Expectations::ExpectationNotMetError, a_string_including(<<~MSG.strip))
          Expected not to send an email but it was sent.
        MSG
      end
    end
  end
end
