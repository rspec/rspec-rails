Feature: view spec

  View specs live in spec/views and render view templates in isolation.

  Scenario: passing spec
    Given a file named "spec/views/widgets/index.html.erb_spec.rb" with:
      """
      require "spec_helper"

      describe "widgets/index.html.erb" do
        it "displays all the widgets" do
          assign(:widgets, [
            stub_model(Widget, :name => "slicer"),
            stub_model(Widget, :name => "dicer")
          ])

          render

          response.should contain("slicer")
          response.should contain("dicer")
        end
      end
      """
    When I run "rspec spec/views"
    Then I should see "1 example, 0 failures"

  Scenario: passing spec with before and nesting
    Given a file named "spec/views/widgets/index.html.erb_spec.rb" with:
      """
      require "spec_helper"

      describe "widgets/index.html.erb" do

        context "with 2 widgets" do
          before(:each) do
            assign(:widgets, [
              stub_model(Widget, :name => "slicer"),
              stub_model(Widget, :name => "dicer")
            ])
          end

          it "displays both widgets" do
            render

            response.should contain("slicer")
            response.should contain("dicer")
          end
        end
      end
      """
    When I run "rspec spec/views"
    Then I should see "1 example, 0 failures"

