Feature: do not render views

  By default, controller specs do not render views. This
  allows you specify which view template an action should
  try to render regardless of whether that template exists
  or compiles cleanly.

  Scenario: expect template that exists and is rendered by controller (passes)
    Given a file named "spec/controllers/widgets_controller_spec.rb" with:
      """
      require "spec_helper.rb"

      describe WidgetsController do
        describe "index" do
          it "renders the index template" do
            get :index
            response.should render_template("index")
          end
          it "renders the widgets/index template" do
            get :index
            response.should render_template("widgets/index")
          end
        end
      end
      """
    When I run "rspec ./spec"
    Then I should see "2 examples, 0 failures"

  Scenario: expect template that exists but is not rendered by controller (fails)
    Given a file named "spec/controllers/widgets_controller_spec.rb" with:
      """
      require "spec_helper.rb"

      describe WidgetsController do
        describe "index" do
          it "renders the 'new' template" do
            get :index
            response.should render_template("new")
          end
        end
      end
      """
    When I run "rspec ./spec"
    Then I should see "1 example, 1 failure"

  Scenario: expect template that does not exist and is not rendered by controller (fails)
    Given a file named "spec/controllers/widgets_controller_spec.rb" with:
      """
      require "spec_helper.rb"

      describe WidgetsController do
        describe "index" do
          it "renders a template that does not exist" do
            get :index
            response.should render_template("does_not_exist")
          end
        end
      end
      """
    When I run "rspec ./spec"
    Then I should see "1 example, 1 failure"
