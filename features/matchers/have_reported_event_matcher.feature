Feature: `have_reported_event` matcher

  The `have_reported_event` matcher is used to check if an event was reported
  via Rails' EventReporter (Rails 8.1+).

  Background:
    Given event reporter is available

  Scenario: Checking event name
    Given a file named "spec/models/user_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe "event reporting" do
        it "matches with event name" do
          expect {
            Rails.event.notify("user.created", { id: 123 })
          }.to have_reported_event("user.created")
        end
      end
      """
    When I run `rspec spec/models/user_spec.rb`
    Then the examples should all pass

  Scenario: Checking event payload
    Given a file named "spec/models/user_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe "event reporting" do
        it "matches with payload" do
          expect {
            Rails.event.notify("user.created", { id: 123, name: "John" })
          }.to have_reported_event("user.created").with_payload(id: 123)
        end
      end
      """
    When I run `rspec spec/models/user_spec.rb`
    Then the examples should all pass

  Scenario: Checking event tags
    Given a file named "spec/models/user_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe "event reporting" do
        it "matches with tags" do
          expect {
            Rails.event.tagged(source: "api") do
              Rails.event.notify("user.created", { id: 123 })
            end
          }.to have_reported_event("user.created").with_tags(source: "api")
        end
      end
      """
    When I run `rspec spec/models/user_spec.rb`
    Then the examples should all pass

  Scenario: Checking event context
    Given a file named "spec/models/user_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe "event reporting" do
        it "matches with context" do
          Rails.event.set_context(request_id: "abc123")
          expect {
            Rails.event.notify("user.created", { id: 123 })
          }.to have_reported_event("user.created").with_context(request_id: "abc123")
          Rails.event.clear_context
        end
      end
      """
    When I run `rspec spec/models/user_spec.rb`
    Then the examples should all pass

  Scenario: Checking event with class-based event object
    Given a file named "app/events/user_created_event.rb" with:
      """ruby
      class UserCreatedEvent
        attr_reader :id, :name

        def initialize(id:, name:)
          @id = id
          @name = name
        end

        def serialize
          { id: @id, name: @name }
        end
      end
      """
    And a file named "spec/models/user_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe "event reporting" do
        it "matches with event class" do
          event = UserCreatedEvent.new(id: 123, name: "John")
          expect {
            Rails.event.notify(event)
          }.to have_reported_event(UserCreatedEvent).with_payload(id: 123)
        end
      end
      """
    When I run `rspec spec/models/user_spec.rb`
    Then the examples should all pass

  Scenario: Using `have_reported_events` for multiple events
    Given a file named "spec/models/user_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe "event reporting" do
        it "matches multiple events regardless of order" do
          expect {
            Rails.event.notify("user.created", { id: 123 })
            Rails.event.notify("email.sent", { to: "john@example.com" })
          }.to have_reported_events([
            { name: "email.sent" },
            { name: "user.created" }
          ])
        end
      end
      """
    When I run `rspec spec/models/user_spec.rb`
    Then the examples should all pass

  Scenario: Using `have_reported_no_event` to check no events reported
    Given a file named "spec/models/user_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe "event reporting" do
        it "passes when no events are reported" do
          expect {
            # no events
          }.to have_reported_no_event
        end

        it "passes when specific event is not reported" do
          expect {
            Rails.event.notify("user.updated", { id: 123 })
          }.to have_reported_no_event("user.created")
        end
      end
      """
    When I run `rspec spec/models/user_spec.rb`
    Then the examples should all pass

  Scenario: Using `with_debug_event_reporting` for debug events
    Given a file named "spec/models/user_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe "event reporting" do
        it "captures debug events within the block" do
          with_debug_event_reporting do
            expect {
              Rails.event.notify("debug.trace", { step: 1 })
            }.to have_reported_event("debug.trace")
          end
        end
      end
      """
    When I run `rspec spec/models/user_spec.rb`
    Then the examples should all pass
