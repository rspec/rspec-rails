Feature: controller spec

  Scenario: simple passing example
    Given a file named "spec/controllers/widgets_controller_spec.rb" with:
      """
      require "spec_helper"

      describe WidgetsController do
        describe "GET index" do
          it "has a 200 status code" do
            get :index
            response.code.should eq("200")
          end
        end
      end
      """
    When I run `rspec spec`
    Then the example should pass

  Scenario: controller is exposed to global before hooks
    Given a file named "spec/controllers/widgets_controller_spec.rb" with:
      """
      require "spec_helper"

      RSpec.configure {|c| c.before { controller.should_not be_nil }}

      describe WidgetsController do
        describe "GET index" do
          it "doesn't matter" do
          end
        end
      end
      """
    When I run `rspec spec`
    Then the example should pass
