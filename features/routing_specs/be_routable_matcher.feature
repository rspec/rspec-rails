Feature: be_routable matcher

  The be_routable matcher is intended for use with should_not to specify
  that a given route should_not be_routable.

  Scenario: with a route that is not routable
    Given a file named "spec/routing/widgets_routing_spec.rb" with:
      """
      require "spec_helper"

      describe WidgetsController do
        it "does not route to widgets/foo/bar" do
          { :get => "/widgets/foo/bar" }.should_not be_routable
        end
      end
      """

    When I run "rspec spec/routing/widgets_routing_spec.rb"
    Then I should see "1 example, 0 failures"
