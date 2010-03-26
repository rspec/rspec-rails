Feature: new_record matcher

  Scenario: new record of correct class
    Given a file named "spec/models/widget_spec.rb" with:
      """
      require "spec_helper"

      describe Widget do
        context "when initialized" do
          it { should be_a_new(Widget) }
        end
      end
      """
    When I run "rspec spec/models/widget_spec.rb"
    Then I should see "1 example, 0 failures"

  Scenario: existing record of correct class

  Scenario: new record of wrong class
  Scenario: existing record of wrong class

