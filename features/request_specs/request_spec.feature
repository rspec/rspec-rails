Feature: request spec

  Scenario: simple request example
    Given a file named "spec/requests/widgets_spec.rb" with:
      """
      require "spec_helper"

      describe "widgets resource" do
        describe "widgets index page" do
          it "contains the widgets header" do
            get "/widgets"
            response.should have_selector("h1", :content => "Listing widgets")
          end
        end
      end
      """
    When I run `rspec spec`
    Then the example should pass

  Scenario: form submission example
    Given a file named "spec/requests/widget_management_spec.rb" with:
      """
      require "spec_helper"

      describe "widget management" do
        it "allows creation of a new widget" do
          get "/widgets/new.html"
          fill_in "Name", :with => "Jack Hammer"
          fill_in "Category", :with => "Tools"
          check "Instock"
          click_button "Create Widget"

          response.should have_selector("#notice", :content => "Widget was successfully created")
        end
      end
      """
    When I run `rspec spec`
    Then the example should pass
