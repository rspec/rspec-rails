Feature: view spec infers controller path

  Scenario:
    Given a file named "app/views/widgets/other.html.erb" with:
      """
      <%= link_to "new", :action => "new" %>
      """
    And a file named "spec/views/widgets/other.html.erb_spec.rb" with:
      """
      require "spec_helper"

      describe "widgets/other.html.erb" do
        it "includes a link to new" do
          render
          rendered.should have_selector("a", :href => "/widgets/new")
        end
      end
      """
    When I run "rspec spec/views"
    Then the output should contain "1 example, 0 failures"

