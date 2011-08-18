Feature: ActiveRecord::Relation match array

  The `=~` matcher can be used with an `ActiveRecord::Relation` (scope). The
  assertion will pass if the scope would return all of the elements specified
  in the array on the right hand side.

  Scenario: example spec with relation =~ matcher
    Given a file named "spec/models/widget_spec.rb" with:
      """
      require "spec_helper"

      describe Widget do
        let!(:widgets) { Array.new(3) { Widget.create } }
        subject { Widget.scoped }

        it { should =~ widgets }
      end
      """
    When I run `rspec spec/models/widget_spec.rb`
    Then the examples should all pass
