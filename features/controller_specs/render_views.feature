Feature: render views

  You can tell a controller example group to render views with the render_views
  declaration.

  Scenario: expect template that exists and is rendered by controller (passes)
    Given a file named "spec/controllers/widgets_controller_spec.rb" with:
      """
      require "spec_helper.rb"

      describe WidgetsController do
        render_views

        describe "index" do
          it "renders the index template" do
            get :index
            response.should contain("Listing widgets")
          end

          it "renders the widgets/index template" do
            get :index
            response.should contain("Listing widgets")
          end
        end
      end
      """
    When I run "rspec spec"
    Then I should see "2 examples, 0 failures"

  Scenario: expect template that does not exist and is rendered by controller (fails)
    Given a file named "spec/controllers/widgets_controller_spec.rb" with:
      """
      require "spec_helper.rb"

      describe WidgetsController do
        render_views

        before do
          def controller.index
            render "other"
          end
        end

        describe "index" do
          it "renders the other template" do
            get :index
          end
        end
      end
      """
    When I run "rspec spec"
    Then I should see "1 example, 1 failure"
    And I should see "Missing template"
