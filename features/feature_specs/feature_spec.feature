Feature: feature spec

  Feature specs are high-level tests meant to exercise slices of functionality
  through an application. They should drive the application only via its
  external interface, usually web pages.

  Feature specs require the [capybara](http://github.com/jnicklas/capybara)
  gem, version 2.0.0 or later. Refer to the [capybara API
  documentation](http://rubydoc.info/github/jnicklas/capybara/master) for more
  information on the methods and matchers that can be used in feature specs.

  The `feature` and `scenario` DSL correspond to `describe` and `it`,
  respectively. These methods are simply aliases that allow feature specs to
  read more as [customer tests](http://c2.com/cgi/wiki?CustomerTest) and
  [acceptance tests](http://c2.com/cgi/wiki?AcceptanceTest).

  Scenario: specify creating a Widget by driving the application with capybara
    Given a file named "spec/features/widget_management_spec.rb" with:
      """ruby
      require "spec_helper"

      feature "Widget management" do
        scenario "User creates a new widget" do
          visit "/widgets/new"

          fill_in "Name", :with => "My Widget"
          click_button "Create Widget"

          expect(page).to have_text("Widget was successfully created.")
        end
      end
      """
    When I run `rspec spec/features/widget_management_spec.rb`
    Then the example should pass
