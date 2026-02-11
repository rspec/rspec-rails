Feature: Rails stats includes spec directories

  Scenario: rails stats finds spec directories when run from a different working directory
    Given rails 8 or later is available
    Given a file named "spec/models/widget_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe Widget, type: :model do
        it "works" do
          expect(true).to be true
        end
      end
      """
    When I run `bash -c "APP=$PWD && cd /tmp && $APP/bin/rails stats"`
    Then the output should contain "Model spec"
