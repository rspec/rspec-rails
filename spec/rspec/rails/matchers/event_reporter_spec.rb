RSpec.describe "have_reported_event", skip: !RSpec::Rails::FeatureCheck.has_event_reporter? do
  describe "without name matching" do
    it "passes when any event is reported" do
      expect { Rails.event.notify("user.created", { id: 123 }) }.to have_reported_event
    end

    it "fails when no events are reported" do
      expect {
        expect { }.to have_reported_event
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /no events reported/)
    end
  end

  describe "basic name matching" do
    it "passes when event is reported" do
      expect { Rails.event.notify("user.created", { id: 123 }) }.to have_reported_event("user.created")
    end

    it "passes with symbol event name" do
      expect { Rails.event.notify(:user_created, { id: 123 }) }.to have_reported_event("user_created")
    end

    it "fails when no events are reported" do
      expect {
        expect { }.to have_reported_event("user.created")
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /no events reported/)
    end

    it "fails when event name doesn't match" do
      expect {
        expect {
          Rails.event.notify("user.updated", { id: 123 })
        }.to have_reported_event("user.created")
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /none of the 1 reported events matched/)
    end
  end

  describe "with payload matching" do
    it "passes with matching payload" do
      expect {
        Rails.event.notify("user.created", { id: 123, name: "John" })
      }.to have_reported_event("user.created").with_payload(id: 123)
    end

    it "passes with partial payload matching" do
      expect {
        Rails.event.notify("user.created", { id: 123, name: "John", email: "john@example.com" })
      }.to have_reported_event("user.created").with_payload(id: 123, name: "John")
    end

    it "passes with regex payload matching" do
      expect {
        Rails.event.notify("user.created", { id: 123, email: "john@example.com" })
      }.to have_reported_event("user.created").with_payload(email: /@example\.com$/)
    end

    it "fails when payload doesn't match" do
      expect {
        expect {
          Rails.event.notify("user.created", { id: 456 })
        }.to have_reported_event("user.created").with_payload(id: 123)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /none of the 1 reported events matched/)
    end

    it "fails when event payload is nil" do
      expect {
        expect {
          Rails.event.notify("user.created", nil)
        }.to have_reported_event("user.created").with_payload(id: 123)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /none of the 1 reported events matched/)
    end

    it "raises ArgumentError when with_payload is called with non-Hash" do
      expect {
        have_reported_event("user.created").with_payload("invalid")
      }.to raise_error(ArgumentError, /with_payload requires a Hash/)
    end
  end

  describe "with tags matching" do
    it "passes with matching tags" do
      expect {
        Rails.event.tagged(request_id: "abc123") do
          Rails.event.notify("user.created", { id: 123 })
        end
      }.to have_reported_event("user.created").with_tags(request_id: "abc123")
    end

    it "passes with regex tag matching" do
      expect {
        Rails.event.tagged(request_id: "abc123") do
          Rails.event.notify("user.created", { id: 123 })
        end
      }.to have_reported_event("user.created").with_tags(request_id: /[a-z0-9]+/)
    end

    it "passes with partial tag matching" do
      expect {
        Rails.event.tagged(request_id: "abc123", user_id: 456) do
          Rails.event.notify("user.created", { id: 123 })
        end
      }.to have_reported_event("user.created").with_tags(request_id: "abc123")
    end

    it "fails when tags don't match" do
      expect {
        expect {
          Rails.event.tagged(request_id: "xyz") do
            Rails.event.notify("user.created", { id: 123 })
          end
        }.to have_reported_event("user.created").with_tags(request_id: "abc123")
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /none of the 1 reported events matched/)
    end

    it "fails when event has no tags" do
      expect {
        expect {
          Rails.event.notify("user.created", { id: 123 })
        }.to have_reported_event("user.created").with_tags(request_id: "abc123")
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /none of the 1 reported events matched/)
    end

    it "fails when expected tag key is missing" do
      expect {
        expect {
          Rails.event.tagged(other_key: "value") do
            Rails.event.notify("user.created", { id: 123 })
          end
        }.to have_reported_event("user.created").with_tags(request_id: /.*/)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /none of the 1 reported events matched/)
    end

    it "raises ArgumentError when with_tags is called with non-Hash" do
      expect {
        have_reported_event("user.created").with_tags("invalid")
      }.to raise_error(ArgumentError, /with_tags requires a Hash/)
    end
  end

  describe "negation" do
    it "passes when event is not reported" do
      expect {
        Rails.event.notify("user.updated", { id: 123 })
      }.not_to have_reported_event("user.created")
    end

    it "passes when no events are reported" do
      expect { }.not_to have_reported_event("user.created")
    end

    it "fails when event is reported" do
      expect {
        expect {
          Rails.event.notify("user.created", { id: 123 })
        }.not_to have_reported_event("user.created")
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /expected no event matching "user.created" to be reported/)
    end

    it "fails when any event is reported and no name specified" do
      expect {
        expect {
          Rails.event.notify("user.created", { id: 123 })
        }.not_to have_reported_event
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /expected no event to be reported, but one was found/)
    end
  end
end

RSpec.describe "have_reported_no_event", skip: !RSpec::Rails::FeatureCheck.has_event_reporter? do
  describe "without filters" do
    it "passes when no events are reported" do
      expect { }.to have_reported_no_event
    end

    it "fails when any event is reported" do
      expect {
        expect {
          Rails.event.notify("user.created", { id: 123 })
        }.to have_reported_no_event
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /expected no events to be reported/)
    end
  end

  describe "with name filter" do
    it "passes when specific event is not reported" do
      expect {
        Rails.event.notify("user.updated", { id: 123 })
      }.to have_reported_no_event("user.created")
    end

    it "fails when specific event is reported" do
      expect {
        expect {
          Rails.event.notify("user.created", { id: 123 })
        }.to have_reported_no_event("user.created")
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /expected no event matching name: "user.created" to be reported/)
    end
  end

  describe "with payload filter" do
    it "passes when no event matches the payload" do
      expect {
        Rails.event.notify("user.created", { id: 456 })
      }.to have_reported_no_event("user.created").with_payload(id: 123)
    end

    it "fails when event matches the payload" do
      expect {
        expect {
          Rails.event.notify("user.created", { id: 123 })
        }.to have_reported_no_event("user.created").with_payload(id: 123)
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /expected no event matching/)
    end

    it "raises ArgumentError when with_payload is called with non-Hash" do
      expect {
        have_reported_no_event("user.created").with_payload("invalid")
      }.to raise_error(ArgumentError, /with_payload requires a Hash/)
    end
  end

  describe "with tags filter" do
    it "passes when no event matches the tags" do
      expect {
        Rails.event.tagged(request_id: "xyz") do
          Rails.event.notify("user.created", { id: 123 })
        end
      }.to have_reported_no_event("user.created").with_tags(request_id: "abc")
    end

    it "fails when event matches the tags" do
      expect {
        expect {
          Rails.event.tagged(request_id: "abc") do
            Rails.event.notify("user.created", { id: 123 })
          end
        }.to have_reported_no_event("user.created").with_tags(request_id: "abc")
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /expected no event matching/)
    end

    it "raises ArgumentError when with_tags is called with non-Hash" do
      expect {
        have_reported_no_event("user.created").with_tags("invalid")
      }.to raise_error(ArgumentError, /with_tags requires a Hash/)
    end
  end

  describe "negation" do
    it "passes when events are reported" do
      expect {
        Rails.event.notify("user.created", { id: 123 })
      }.not_to have_reported_no_event
    end

    it "fails when no events are reported" do
      expect {
        expect { }.not_to have_reported_no_event
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /expected at least one event to be reported/)
    end

    it "passes when matching event is reported (with name filter)" do
      expect {
        Rails.event.notify("user.created", { id: 123 })
      }.not_to have_reported_no_event("user.created")
    end

    it "fails when no matching event is reported (with name filter)" do
      expect {
        expect {
          Rails.event.notify("user.updated", { id: 123 })
        }.not_to have_reported_no_event("user.created")
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /expected an event matching name: "user.created" to be reported/)
    end
  end
end

RSpec.describe "have_reported_events", skip: !RSpec::Rails::FeatureCheck.has_event_reporter? do
  describe "basic matching" do
    it "passes when no events expected and none reported" do
      expect { }.to have_reported_events([])
    end

    it "passes when all events are reported" do
      expect {
        Rails.event.notify("user.created", { id: 123 })
        Rails.event.notify("email.sent", { to: "user@example.com" })
      }.to have_reported_events([
        { name: "user.created", payload: { id: 123 } },
        { name: "email.sent" }
      ])
    end

    it "passes regardless of order" do
      expect {
        Rails.event.notify("email.sent", { to: "user@example.com" })
        Rails.event.notify("user.created", { id: 123 })
      }.to have_reported_events([
        { name: "user.created", payload: { id: 123 } },
        { name: "email.sent" }
      ])
    end

    it "fails when no events are reported" do
      expect {
        expect { }.to have_reported_events([
          { name: "user.created" }
        ])
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /no events reported/)
    end

    it "fails when some events are missing" do
      expect {
        expect {
          Rails.event.notify("user.created", { id: 123 })
        }.to have_reported_events([
          { name: "user.created" },
          { name: "email.sent" }
        ])
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /some were missing/)
    end
  end

  describe "with tags matching" do
    it "supports tag matching with regex" do
      expect {
        Rails.event.tagged(request_id: "123") do
          Rails.event.notify("user.created", { id: 123 })
          Rails.event.notify("email.sent", { to: "user@example.com" })
        end
      }.to have_reported_events([
        { name: "user.created", tags: { request_id: /\d+/ } },
        { name: "email.sent" }
      ])
    end
  end

  describe "negation" do
    it "passes when not all events are reported" do
      expect {
        Rails.event.notify("user.created", { id: 123 })
      }.not_to have_reported_events([
        { name: "user.created" },
        { name: "email.sent" }
      ])
    end

    it "fails when all events are reported" do
      expect {
        expect {
          Rails.event.notify("user.created", { id: 123 })
          Rails.event.notify("email.sent", { to: "user@example.com" })
        }.not_to have_reported_events([
          { name: "user.created" },
          { name: "email.sent" }
        ])
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError, /expected events not to be reported, but all were found/)
    end
  end
end

RSpec.describe "with_debug_event_reporting", skip: !RSpec::Rails::FeatureCheck.has_event_reporter? do
  around do |example|
    original_debug_mode = ActiveSupport.event_reporter.debug_mode?
    example.run
    ActiveSupport.event_reporter.debug_mode = original_debug_mode
  end

  it "enables debug events within the block" do
    with_debug_event_reporting do
      expect {
        Rails.event.debug("debug.event", { data: "test" })
      }.to have_reported_event("debug.event")
    end
  end

  it "does not report debug events when debug_mode is disabled" do
    ActiveSupport.event_reporter.debug_mode = false
    expect {
      Rails.event.debug("debug.event", { data: "test" })
    }.to have_reported_no_event("debug.event")
  end

  it "reports debug events when debug_mode is enabled via with_debug_event_reporting" do
    ActiveSupport.event_reporter.debug_mode = false
    with_debug_event_reporting do
      expect {
        Rails.event.debug("debug.event", { data: "test" })
      }.to have_reported_event("debug.event")
    end
  end

  it "restores original debug_mode after the block" do
    ActiveSupport.event_reporter.debug_mode = false
    with_debug_event_reporting do
      expect(ActiveSupport.event_reporter.debug_mode?).to be_truthy
    end
    expect(ActiveSupport.event_reporter.debug_mode?).to be_falsey
  end
end
