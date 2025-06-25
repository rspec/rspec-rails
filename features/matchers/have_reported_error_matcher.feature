Feature: `have_reported_error` matcher

  The `have_reported_error` matcher is used to check if an error was reported
  to Rails error reporting system (`Rails.error`). It can match against error
  classes, instances, messages, and attributes.

  The matcher supports several matching strategies:
  * Any error reported
  * A specific error class
  * Specific error instance with message
  * Error message patterns using regular expressions
  * Error attributes using `.with()`
  * Symbol errors

  The matcher is available in all spec types where Rails error reporting is used.

  Background:
    Given a file named "app/models/user.rb" with:
      """ruby
      class User < ApplicationRecord
        class ValidationError < StandardError; end
        def self.process_data
          Rails.error.report(StandardError.new("Processing failed"))
        end

        def self.process_with_context
          Rails.error.report(ArgumentError.new("Invalid input"), context: "user_processing", severity: "high")
        end

        def self.process_custom_error
          Rails.error.report(ValidationError.new("Email is invalid"))
        end
      end
      """

  Scenario: Checking for any error being reported
    Given a file named "spec/models/user_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe User do
        it "reports errors" do
          expect {
            User.process_data
          }.to have_reported_error
        end
      end
      """
    When I run `rspec spec/models/user_spec.rb`
    Then the examples should all pass

  Scenario: Checking for a specific error class
    Given a file named "spec/models/user_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe User do
        it "reports a StandardError" do
          expect {
            User.process_data
          }.to have_reported_error(StandardError)
        end

        it "reports an ArgumentError" do
          expect {
            User.process_with_context
          }.to have_reported_error(ArgumentError)
        end
      end
      """
    When I run `rspec spec/models/user_spec.rb`
    Then the examples should all pass

  Scenario: Checking for specific error instance with message
    Given a file named "spec/models/user_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe User do
        it "reports error with specific message" do
          expect {
            User.process_data
          }.to have_reported_error(StandardError.new("Processing failed"))
        end

        it "reports ArgumentError with specific message" do
          expect {
            User.process_with_context
          }.to have_reported_error(ArgumentError.new("Invalid input"))
        end
      end
      """
    When I run `rspec spec/models/user_spec.rb`
    Then the examples should all pass

  Scenario: Checking error messages using regular expressions
    Given a file named "spec/models/user_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe User do
        it "reports errors with a message matching a pattern" do
          expect {
            User.process_data
          }.to have_reported_error(/Processing/)
        end
      end
      """
    When I run `rspec spec/models/user_spec.rb`
    Then the examples should all pass

  Scenario: Constraining error matches to their attributes using `with`
    Given a file named "spec/models/user_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe User do
        it "reports error with specific context" do
          expect {
            User.process_with_context
          }.to have_reported_error.with(context: "user_processing")
        end

        it "reports error with multiple attributes" do
          expect {
            User.process_with_context
          }.to have_reported_error(ArgumentError).with(context: "user_processing", severity: "high")
        end
      end
      """
    When I run `rspec spec/models/user_spec.rb`
    Then the examples should all pass

  Scenario: Checking custom error classes
    Given a file named "spec/models/user_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe User do
        it "reports a ValidationError" do
          expect {
            User.process_custom_error
          }.to have_reported_error(ValidationError)
        end

        it "reports ValidationError with specific message" do
          expect {
            User.process_custom_error
          }.to have_reported_error(ValidationError.new("Email is invalid"))
        end
      end
      """
    When I run `rspec spec/models/user_spec.rb`
    Then the examples should all pass

  Scenario: Using negation - expecting no errors
    Given a file named "spec/models/user_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe User do
        it "does not report any errors for safe operations" do
          expect {
            # Safe operation that doesn't report errors
            "safe code"
          }.not_to have_reported_error
        end
      end
      """
    When I run `rspec spec/models/user_spec.rb`
    Then the examples should all pass

  Scenario: Using in controller specs
    Given a file named "spec/controllers/users_controller_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe UsersController, type: :controller do
        describe "POST #create" do
          it "reports validation errors" do
            expect {
              post :create, params: { user: { email: "invalid" } }
            }.to have_reported_error(ValidationError)
          end
        end
      end
      """
    When I run `rspec spec/controllers/users_controller_spec.rb`
    Then the examples should all pass

  Scenario: Using in request specs
    Given a file named "spec/requests/users_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe "Users", type: :request do
        describe "POST /users" do
          it "reports processing errors" do
            expect {
              post "/users", params: { user: { name: "Test" } }
            }.to have_reported_error.with(context: "user_creation")
          end
        end
      end
      """
    When I run `rspec spec/requests/users_spec.rb`
    Then the examples should all pass

  Scenario: Complex error matching with multiple conditions
    Given a file named "spec/models/user_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe User do
        it "reports error with class, message pattern, and attributes" do
          expect {
            Rails.error.report(
              ArgumentError.new("Invalid user data provided"),
              context: "validation",
              severity: "critical",
              user_id: 123
            )
          }.to have_reported_error(ArgumentError)
            .with(context: "validation", severity: "critical")
        end
      end
      """
    When I run `rspec spec/models/user_spec.rb`
    Then the examples should all pass