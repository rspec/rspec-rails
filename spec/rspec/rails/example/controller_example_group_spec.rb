require "spec_helper"

module RSpec::Rails
  describe ControllerExampleGroup do
    it "is included in specs in ./spec/controllers" do
      stub_metadata(
        :example_group => {:file_path => "./spec/controllers/whatever_spec.rb:15"}
      )
      group = RSpec::Core::ExampleGroup.describe
      group.included_modules.should include(ControllerExampleGroup)
    end
  end
end
