require "spec_helper"

module RSpec::Rails
  describe RequestExampleGroup do
    it "is included in specs in ./spec/requests" do
      stub_metadata(
        :example_group => {:file_path => "./spec/requests/whatever_spec.rb:15"}
      )
      group = RSpec::Core::ExampleGroup.describe
      group.included_modules.should include(RequestExampleGroup)
    end
  end
end
