Feature: System spec

    System specs are RSpec's wrapper around Rails' own
    [system tests](https://guides.rubyonrails.org/testing.html#system-testing).

    > System tests allow you to test user interactions with your application,
    > running tests in either a real or a headless browser. System tests use
    > Capybara under the hood.
    >
    > By default, system tests are run with the Selenium driver, using the
    > Chrome browser, and a screen size of 1400x1400. The next section explains
    > how to change the default settings.

    System specs are marked by setting type to :system, e.g. `:type => :system`.

    The Capybara gem is automatically required, and Rails includes it in
    generated application Gemfiles. Configure a webserver (e.g.
    `Capybara.server = :webrick`) before attempting to use system specs.

    RSpec **does not** use your `ApplicationSystemTestCase` helper. Instead it
    uses the default `driven_by(:selenium)` from Rails. If you want to override
    this behaviour you can call `driven_by` manually in a test.

    System specs run in a transaction. So unlike feature specs with
    javascript, you do not need [DatabaseCleaner](https://github.com/DatabaseCleaner/database_cleaner).

    @system_test
    Scenario: System specs
        Given a file named "spec/system/widget_system_spec.rb" with:
          """ruby
          require "rails_helper"

          RSpec.describe "Widget management", :type => :system do
            before do
              driven_by(:rack_test)
            end

            it "enables me to create widgets" do
              visit "/widgets/new"

              fill_in "Name", :with => "My Widget"
              click_button "Create Widget"

              expect(page).to have_text("Widget was successfully created.")
            end
          end
          """
        When I run `rspec spec/system/widget_system_spec.rb`
        Then the exit status should be 0
        And the output should contain "1 example, 0 failures"
