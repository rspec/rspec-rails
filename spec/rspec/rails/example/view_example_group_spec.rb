require "spec_helper"

describe ViewExampleGroupBehaviour do
  it "is included in specs in ./spec/views" do
    stub_metadata(
      :example_group => {:file_path => "./spec/views/whatever_spec.rb:15"}
    )
    group = RSpec::Core::ExampleGroup.describe
    group.included_modules.should include(ViewExampleGroupBehaviour)
  end
end
