Feature: helper spec
  
  Helper specs live in `spec/helpers`, or any example group with `:type =>
  :helper`. In order to access the helper methods you can call them on the
  `helper` object.
  
  Scenario: helper method that returns true
    Given a file named "spec/helpers/application_helper_spec.rb" with:
      """
      require "spec_helper"
      
      describe ApplicationHelper do
        describe "#page_title" do
          it "returns true" do
            helper.page_title.should be_true
          end
        end
      end
      """
    And a file named "app/helpers/application_helper.rb" with:
      """
      module ApplicationHelper
        def page_title
          true
        end
      end
      """
    When I run "rspec spec/helpers/application_helper_spec.rb"
    Then the output should contain "1 example, 0 failures"
    
  Scenario: helper method that accesses an instance variable
    Given a file named "spec/helpers/application_helper_spec.rb" with:
      """
      require "spec_helper"

      describe ApplicationHelper do
        describe "#page_title" do
          it "returns the instance variable" do
            assign(:title, "My Title")
            helper.page_title.should eql("My Title")
          end
        end
      end
      """
    And a file named "app/helpers/application_helper.rb" with:
      """
      module ApplicationHelper
        def page_title
          @title || nil
        end
      end
      """
    When I run "rspec spec/helpers/application_helper_spec.rb"
    Then the output should contain "1 example, 0 failures"

  Scenario: application helper is included in helper object
    Given a file named "spec/helpers/widgets_helper_spec.rb" with:
      """
      require "spec_helper"

      describe WidgetsHelper do
        describe "#page_title" do
          it "includes the app name" do
            assign(:title, "This Page")
            helper.page_title.should eq("The App: This Page")
          end
        end
      end
      """
    And a file named "app/helpers/application_helper.rb" with:
      """
      module ApplicationHelper
        def app_name
          "The App"
        end
      end
      """
    And a file named "app/helpers/widgets_helper.rb" with:
      """
      module WidgetsHelper
        def page_title
          "#{app_name}: #{@title}"
        end
      end
      """
    When I run "rspec spec/helpers/widgets_helper_spec.rb"
    Then the output should contain "1 example, 0 failures"
