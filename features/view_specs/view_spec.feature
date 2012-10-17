Feature: view spec

  View specs live in spec/views and render view templates in isolation.

  Scenario: passing spec that renders the described view file
    Given a file named "spec/views/widgets/index.html.erb_spec.rb" with:
      """ruby
      require "spec_helper"

      describe "widgets/index" do
        it "displays all the widgets" do
          assign(:widgets, [
            stub_model(Widget, :name => "slicer"),
            stub_model(Widget, :name => "dicer")
          ])

          render

          expect(rendered).to match /slicer/
          expect(rendered).to match /dicer/
        end
      end
      """
    When I run `rspec spec/views`
    Then the examples should all pass

  Scenario: passing spec with before and nesting
    Given a file named "spec/views/widgets/index.html.erb_spec.rb" with:
      """ruby
      require "spec_helper"

      describe "widgets/index" do

        context "with 2 widgets" do
          before(:each) do
            assign(:widgets, [
              stub_model(Widget, :name => "slicer"),
              stub_model(Widget, :name => "dicer")
            ])
          end

          it "displays both widgets" do
            render

            expect(rendered).to match /slicer/
            expect(rendered).to match /dicer/
          end
        end
      end
      """
    When I run `rspec spec/views`
    Then the examples should all pass

  Scenario: passing spec with explicit template rendering
    Given a file named "spec/views/widgets/widget.html.erb_spec.rb" with:
      """ruby
      require "spec_helper"

      describe "rendering the widget template" do
        it "displays the widget" do
          assign(:widget, stub_model(Widget, :name => "slicer"))

          render :template => "widgets/widget.html.erb"

          expect(rendered).to match /slicer/
        end
      end
      """
    And a file named "app/views/widgets/widget.html.erb" with:
      """
      <h2><%= @widget.name %></h2>
      """
    When I run `rspec spec/views`
    Then the examples should all pass

  Scenario: passing spec with a description that includes the format and handler
    Given a file named "spec/views/widgets/widget.xml.erb_spec.rb" with:
      """ruby
      require "spec_helper"

      describe "widgets/widget.html.erb" do
        it "renders the HTML template" do
          render

          expect(rendered).to match /HTML/
        end
      end

      describe "widgets/widget.xml.erb" do
        it "renders the XML template" do
          render

          expect(rendered).to match /XML/
        end
      end
      """
    And a file named "app/views/widgets/widget.html.erb" with:
      """
      HTML
      """
    And a file named "app/views/widgets/widget.xml.erb" with:
      """
      XML
      """
    When I run `rspec spec/views`
    Then the examples should all pass

  Scenario: passing spec with rendering of locals in a partial
    Given a file named "spec/views/widgets/_widget.html.erb_spec.rb" with:
      """ruby
      require "spec_helper"

      describe "rendering locals in a partial" do
        it "displays the widget" do
          widget = stub_model(Widget, :name => "slicer")

          render :partial => "widgets/widget.html.erb", :locals => {:widget => widget}

          expect(rendered).to match /slicer/
        end
      end
      """
    And a file named "app/views/widgets/_widget.html.erb" with:
      """
      <h3><%= widget.name %></h3>
      """
    When I run `rspec spec/views`
    Then the examples should all pass

  Scenario: passing spec with rendering of locals in an implicit partial
    Given a file named "spec/views/widgets/_widget.html.erb_spec.rb" with:
      """ruby
      require "spec_helper"

      describe "rendering locals in a partial" do
        it "displays the widget" do
          widget = stub_model(Widget, :name => "slicer")

          render "widgets/widget", :widget => widget

          expect(rendered).to match /slicer/
        end
      end
      """
    And a file named "app/views/widgets/_widget.html.erb" with:
      """
      <h3><%= widget.name %></h3>
      """
    When I run `rspec spec/views`
    Then the examples should all pass

  Scenario: passing spec with rendering of text
    Given a file named "spec/views/widgets/direct.html.erb_spec.rb" with:
      """ruby
      require "spec_helper"

      describe "rendering text directly" do
        it "displays the given text" do

          render :text => "This is directly rendered"

          expect(rendered).to match /directly rendered/
        end
      end
      """
    When I run `rspec spec/views`
    Then the examples should all pass

  Scenario: passing view spec that stubs a helper method
    Given a file named "app/views/secrets/index.html.erb" with:
      """
      <%- if admin? %>
        <h1>Secret admin area</h1>
      <%- end %>
      """
    And a file named "spec/views/secrets/index.html.erb_spec.rb" with:
      """ruby
      require 'spec_helper'

      describe 'secrets/index' do
        before do
          view.stub(:admin?).and_return(true)
        end

        it 'checks for admin access' do
          render
          expect(rendered).to match /Secret admin area/
        end
      end
      """
    When I run `rspec spec/views/secrets`
    Then the examples should all pass

  Scenario: request.path_parameters should match Rails by using symbols for keys
    Given a file named "spec/views/widgets/index.html.erb_spec.rb" with:
      """ruby
      require "spec_helper"

      describe "controller.request.path_parameters" do
        it "matches the Rails environment by using symbols for keys" do
          [:controller, :action].each { |k| expect(controller.request.path_parameters.keys).to include(k) }
        end
      end
      """
    When I run `rspec spec/views`
    Then the examples should all pass
