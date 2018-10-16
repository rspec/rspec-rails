Feature: view spec

  View specs should be placed in `spec/views`,
  and verify the content of view templates in isolation
  (that is, without invoking a controller).

  Overview
  --------

  View specs generally follow three steps:

  ```ruby
  assign(:widget, Widget.new)  # sets @widget = Widget.new in the view template

  render

  expect(rendered).to match(/text/)
  ```

  1. Use the `assign` method to set instance variables in the view.
     Technically, `@widget = Widget.new` would work too,
     but RSpec doesn't officially support this pattern.
     (It only works as a side effect of the fact that
     view specs include `ActionView::TestCase` behavior.
     Be aware that it may be made unavailable in the future.)

  2. Use the `render` method to render the view.

  3. Set expectations against the resulting `rendered` object.

  Notes
  -----

  * To apply a layout to the view template being rendered,
    be sure to specify both the template and layout explicitly:

    ```ruby
    render :template => "events/show", :layout => "layouts/application"
    ```

  * View specs expose a `controller` object,
    which can be used to set expectations about the route (path + parameters)
    to the view template being tested.
    Some attributes of this object are based on
    the name of the view itself—that is, in a spec for `events/index.html.erb`:

    * `controller.controller_path == "events"`
    * `controller.request.path_parameters[:controller] == "events"`

    Be careful of these automatically-inferred values
    when writing specs for partials
    (which may be shared across multiple controllers).

  Scenario: View specs render the described view file
    Given a file named "spec/views/widgets/index.html.erb_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe "widgets/index" do
        it "displays all the widgets" do
          assign(:widgets, [
            Widget.create!(:name => "slicer"),
            Widget.create!(:name => "dicer")
          ])

          render

          expect(rendered).to match /slicer/
          expect(rendered).to match /dicer/
        end
      end
      """
    When I run `rspec spec/views`
    Then the examples should all pass

  Scenario: View specs can have before block and nesting
    Given a file named "spec/views/widgets/index.html.erb_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe "widgets/index" do

        context "with 2 widgets" do
          before(:each) do
            assign(:widgets, [
              Widget.create!(:name => "slicer"),
              Widget.create!(:name => "dicer")
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

  Scenario: View specs can explicitly render templates
    Given a file named "spec/views/widgets/widget.html.erb_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe "rendering the widget template" do
        it "displays the widget" do
          assign(:widget, Widget.create!(:name => "slicer"))

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

  Scenario: View specs can have description that includes the format and handler
    Given a file named "spec/views/widgets/widget.xml.erb_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe "widgets/widget.html.erb" do
        it "renders the HTML template" do
          render

          expect(rendered).to match /HTML/
        end
      end

      RSpec.describe "widgets/widget.xml.erb" do
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

  Scenario: View specs can render locals in a partial
    Given a file named "spec/views/widgets/_widget.html.erb_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe "rendering locals in a partial" do
        it "displays the widget" do
          widget = Widget.create!(:name => "slicer")

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

  Scenario: View specs can render locals in an implicit partial
    Given a file named "spec/views/widgets/_widget.html.erb_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe "rendering locals in a partial" do
        it "displays the widget" do
          widget = Widget.create!(:name => "slicer")

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

  @rails_pre_5
  Scenario: View specs can render text
    Given a file named "spec/views/widgets/direct.html.erb_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe "rendering text directly" do
        it "displays the given text" do

          render :text => "This is directly rendered"

          expect(rendered).to match /directly rendered/
        end
      end
      """
    When I run `rspec spec/views`
    Then the examples should all pass

  @rails_post_5
  Scenario: View specs can render text
    Given a file named "spec/views/widgets/direct.html.erb_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe "rendering text directly" do
        it "displays the given text" do

          render :plain => "This is directly rendered"

          expect(rendered).to match /directly rendered/
        end
      end
      """
    When I run `rspec spec/views`
    Then the examples should all pass

  Scenario: View specs can stub a helper method
    Given a file named "app/helpers/application_helper.rb" with:
      """ruby
      module ApplicationHelper
        def admin?
          false
        end
      end
      """
    And a file named "app/views/secrets/index.html.erb" with:
      """
      <%- if admin? %>
        <h1>Secret admin area</h1>
      <%- end %>
      """
    And a file named "spec/views/secrets/index.html.erb_spec.rb" with:
      """ruby
      require 'rails_helper'

      RSpec.describe 'secrets/index' do
        before do
          allow(view).to receive(:admin?).and_return(true)
        end

        it 'checks for admin access' do
          render
          expect(rendered).to match /Secret admin area/
        end
      end
      """
    When I run `rspec spec/views/secrets`
    Then the examples should all pass

  Scenario: View specs use symbols for keys in `request.path_parameters` to match Rails style
    Given a file named "spec/views/widgets/index.html.erb_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe "controller.request.path_parameters" do
        it "matches the Rails environment by using symbols for keys" do
          [:controller, :action].each { |k| expect(controller.request.path_parameters.keys).to include(k) }
        end
      end
      """
    When I run `rspec spec/views`
    Then the examples should all pass

  Scenario: View spec actions that do not require extra parameters have `request.fullpath` set
    Given a file named "spec/views/widgets/index.html.erb_spec.rb" with:
    """ruby
      require "rails_helper"

      RSpec.describe "widgets/index" do
        it "has a request.fullpath that is defined" do
          expect(controller.request.fullpath).to eq widgets_path
        end
      end
      """
    When I run `rspec spec/views`
    Then the examples should all pass

  Scenario: View spec actions that require extra parameters have `request.fullpath` set when the developer supplies them
    Given a file named "spec/views/widgets/show.html.erb_spec.rb" with:
    """ruby
      require "rails_helper"

      RSpec.describe "widgets/show" do
        it "displays the widget with id: 1" do
          widget = Widget.create!(:name => "slicer")
          controller.extra_params = { :id => widget.id }

          expect(controller.request.fullpath).to eq widget_path(widget)
        end
      end
      """
    When I run `rspec spec/views`
    Then the examples should all pass
