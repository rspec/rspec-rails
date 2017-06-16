Feature: System spec

    System specs are RSpec's wrapper around Rails' own
    [system tests](http://guides.rubyonrails.org/testing.html#system-testing).
    We encourage you to familiarse yourself with their documentation.

    RSpec **does not** use your `ApplicationSystemTestCase` helper. Instead it uses
    the default `driven_by(:selenium)` from Rails. If you want to override this
    behaviour you can call `driven_by` manually in a test.


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
