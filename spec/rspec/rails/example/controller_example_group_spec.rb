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

    it "includes routing matchers" do
      group = RSpec::Core::ExampleGroup.describe do
        include ControllerExampleGroup
      end
      group.included_modules.should include(RSpec::Rails::Matchers::RoutingMatchers)
    end
  end
end
