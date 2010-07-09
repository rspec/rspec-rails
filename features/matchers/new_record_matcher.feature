Feature: be_a_new matcher

  The be_a_new matcher accepts a class and passes if the subject is an instance
  of that class that returns true to new_record?

  Scenario: example spec with four possibilities 
    Given a file named "spec/models/widget_spec.rb" with:
      """
      require "spec_helper"

      describe Widget do
        context "when initialized" do
          subject { Widget.new }
          it { should be_a_new(Widget) }
          it { should_not be_a_new(String) }
        end
        context "when saved" do
          subject { Widget.create }
          it { should_not be_a_new(Widget) }
          it { should_not be_a_new(String) }
        end
      end
      """
    When I run "rspec spec/models/widget_spec.rb"
    Then the output should contain "4 examples, 0 failures"
