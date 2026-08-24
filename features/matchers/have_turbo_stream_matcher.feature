Feature: `have_turbo_stream` matcher

  The `have_turbo_stream` matcher is used to check if a response contains a
  `<turbo-stream>` element with a specific action and target.

  The `be_turbo_stream` matcher checks if the response has the Turbo Stream
  content type (`text/vnd.turbo-stream.html`).

  The `have_turbo_frame` matcher checks if a response contains a
  `<turbo-frame>` element with a specific id.

  Background:
    Given turbo testing is available

  Scenario: Checking for a turbo stream element by action and target
    Given a file named "spec/requests/posts_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe "Posts turbo stream", type: :request do
        it "matches a turbo stream element" do
          body = '<turbo-stream action="append" target="posts"><template><div>New post</div></template></turbo-stream>'
          response = double("response", body: body)
          expect(response).to have_turbo_stream(action: "append", target: "posts")
        end
      end
      """
    When I run `rspec spec/requests/posts_spec.rb`
    Then the examples should all pass

  Scenario: Checking for a turbo stream element with targets (CSS selector)
    Given a file named "spec/requests/comments_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe "Comments turbo stream", type: :request do
        it "matches a turbo stream element with targets" do
          body = '<turbo-stream action="update" targets=".comment"><template><div>Updated</div></template></turbo-stream>'
          response = double("response", body: body)
          expect(response).to have_turbo_stream(action: "update", targets: ".comment")
        end
      end
      """
    When I run `rspec spec/requests/comments_spec.rb`
    Then the examples should all pass

  Scenario: Checking turbo stream element count
    Given a file named "spec/requests/messages_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe "Messages turbo stream", type: :request do
        it "matches the expected count of turbo stream elements" do
          body = <<~HTML
            <turbo-stream action="append" target="messages"><template><div>One</div></template></turbo-stream>
            <turbo-stream action="append" target="messages"><template><div>Two</div></template></turbo-stream>
          HTML
          response = double("response", body: body)
          expect(response).to have_turbo_stream(action: "append", target: "messages").with_count(2)
        end
      end
      """
    When I run `rspec spec/requests/messages_spec.rb`
    Then the examples should all pass

  Scenario: Checking for a turbo frame element
    Given a file named "spec/requests/form_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe "Form turbo frame", type: :request do
        it "matches a turbo frame element" do
          body = '<turbo-frame id="post_form"><form action="/posts"><input type="text" name="title"></form></turbo-frame>'
          response = double("response", body: body)
          expect(response).to have_turbo_frame("post_form")
        end
      end
      """
    When I run `rspec spec/requests/form_spec.rb`
    Then the examples should all pass
