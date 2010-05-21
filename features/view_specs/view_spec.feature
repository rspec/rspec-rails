Feature: view spec

  View specs live in spec/views and render view templates in isolation.

  Scenario: passing spec that renders the described view file
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

  Scenario: passing spec with explicit template rendering
    Given a file named "spec/views/widgets/widget.html.erb_spec.rb" with:
      """
      require "spec_helper"

      describe "rendering the widget template" do
        it "displays the widget" do
          assign(:widget, stub_model(Widget, :name => "slicer"))

          render :template => "widgets/widget.html.erb"

          response.should contain("slicer")
        end
      end
      """
    And a file named "app/views/widgets/widget.html.erb" with:
      """
      <h2><%= @widget.name %></h2>
      """
    When I run "rspec spec/views"
    Then I should see "1 example, 0 failures"

  Scenario: passing spec with rendering of locals in a partial
    Given a file named "spec/views/widgets/_widget.html.erb_spec.rb" with:
      """
      require "spec_helper"

      describe "rendering locals in a partial" do
        it "displays the widget" do
          widget = stub_model(Widget, :name => "slicer")

          render :partial => "widgets/widget.html.erb", :locals => {:widget => widget}

          response.should contain("slicer")
        end
      end
      """
    And a file named "app/views/widgets/_widget.html.erb" with:
      """
      <h3><%= widget.name %></h3>
      """
    When I run "rspec spec/views"
    Then I should see "1 example, 0 failures"

  Scenario: passing spec with rendering of locals in an implicit partial
    Given a file named "spec/views/widgets/_widget.html.erb_spec.rb" with:
      """
      require "spec_helper"

      describe "rendering locals in a partial" do
        it "displays the widget" do
          widget = stub_model(Widget, :name => "slicer")

          render "widgets/widget", :widget => widget

          response.should contain("slicer")
        end
      end
      """
    And a file named "app/views/widgets/_widget.html.erb" with:
      """
      <h3><%= widget.name %></h3>
      """
    When I run "rspec spec/views"
    Then I should see "1 example, 0 failures"

  Scenario: passing spec with rendering of text
    Given a file named "spec/views/widgets/direct.html.erb_spec.rb" with:
      """
      require "spec_helper"

      describe "rendering text directly" do
        it "displays the given text" do

          render :text => "This is directly rendered"

          response.should contain("directly rendered")
        end
      end
      """
    When I run "rspec spec/views"
    Then I should see "1 example, 0 failures"

  Scenario: passing spec with rendering of Prototype helper update
    Given a file named "spec/views/widgets/prototype_update.html.erb_spec.rb" with:
      """
      require "spec_helper"

      describe "render a Prototype helper update" do
        it "hides the status indicator" do

          render :update do |page|
            page.hide 'status-indicator'
          end

          response.should contain("Element.hide(\"status-indicator\")")
        end
      end
      """
    When I run "rspec spec/views"
    Then I should see "1 example, 0 failures"
