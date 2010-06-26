require "spec_helper"

module RSpec::Rails
  describe ControllerExampleGroup do
    it { should be_included_in_files_in('./spec/controllers/') }
    it { should be_included_in_files_in('.\\spec\\controllers\\') }

    it "includes routing matchers" do
      group = RSpec::Core::ExampleGroup.describe do
        include ControllerExampleGroup
      end
      group.included_modules.should include(RSpec::Rails::Matchers::RoutingMatchers)
    end
  end
end
