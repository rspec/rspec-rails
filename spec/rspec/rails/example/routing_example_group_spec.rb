require "spec_helper"

module RSpec::Rails
  describe RoutingExampleGroup do
    it "is included in specs in ./spec/routing" do
      stub_metadata(
        :example_group => {:file_path => "./spec/routing/whatever_spec.rb:15"}
      )
      group = RSpec::Core::ExampleGroup.describe
      group.included_modules.should include(RoutingExampleGroup)
    end
  end
end
