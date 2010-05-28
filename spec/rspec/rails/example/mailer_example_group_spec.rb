require "spec_helper"

module RSpec::Rails
  describe MailerExampleGroup do
    it "is included in specs in ./spec/mailers" do
      stub_metadata(
        :example_group => {:file_path => "./spec/mailers/whatever_spec.rb:15"}
      )
      group = RSpec::Core::ExampleGroup.describe
      group.included_modules.should include(MailerExampleGroup)
    end
  end
end
