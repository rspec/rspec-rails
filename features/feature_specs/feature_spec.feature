Feature: feature spec

  Feature specs are high-level tests meant to exercise slices of functionality
  through an application. They should drive the application only via its
  external interface, usually web pages.

  Feature specs are marked by `:type => :feature` or if you have set
  `config.infer_spec_type_from_file_location!` by placing them in `spec/features`.

  Feature specs require the [capybara](http://github.com/jnicklas/capybara)
  gem, version 2.2.0 or later (we recommend 2.3.0 or later to avoid some
  deprecation warnings). Refer to the [capybara API
  documentation](http://rubydoc.info/github/jnicklas/capybara/master) for more
  information on the methods and matchers that can be used in feature specs.

  The `feature` and `scenario` DSL correspond to `describe` and `it`,
  respectively. These methods are simply aliases that allow feature specs to
  read more as [customer tests](http://c2.com/cgi/wiki?CustomerTest) and
  [acceptance tests](http://c2.com/cgi/wiki?AcceptanceTest). They set
  `:type => :feature` automatically for you.

  Scenario: Feature specs are skipped without Capybara
    Given a file named "spec/features/widget_management_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.feature "Widget management", :type => :feature do
        scenario "User creates a new widget" do
          visit "/widgets/new"

          fill_in "Name", :with => "My Widget"
          click_button "Create Widget"

          expect(page).to have_text("Widget was successfully created.")
        end
      end
      """
    When I run `rspec spec/features/widget_management_spec.rb`
    Then the exit status should be 0
    And the output should contain "1 example, 0 failures, 1 pending"
    And the output should contain:
      """
      Pending:
        Widget management User creates a new widget
          # Feature specs require the Capybara (http://github.com/jnicklas/capybara) gem, version 2.2.0 or later. We recommend version 2.4.0 or later to avoid some deprecation warnings and have support for `config.disable_monkey_patching!` mode.
          # ./spec/features/widget_management_spec.rb:4
      """

  @capybara
  Scenario: specify creating a Widget by driving the application with capybara
    Given a file named "spec/features/widget_management_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.feature "Widget management", :type => :feature do
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
