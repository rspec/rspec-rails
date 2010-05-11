require "spec_helper"

describe RequestExampleGroupBehaviour do
  it "is included in specs in ./spec/requests" do
    stub_metadata(
      :example_group => {:file_path => "./spec/requests/whatever_spec.rb:15"}
    )
    group = Rspec::Core::ExampleGroup.describe
    group.included_modules.should include(RequestExampleGroupBehaviour)
  end
end
