require "spec_helper"

describe MailerExampleGroupBehaviour do
  it "is included in specs in ./spec/mailers" do
    stub_metadata(
      :example_group => {:file_path => "./spec/mailers/whatever_spec.rb:15"}
    )
    group = RSpec::Core::ExampleGroup.describe
    group.included_modules.should include(MailerExampleGroupBehaviour)
  end
end
