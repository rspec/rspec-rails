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

    it "adds :type => :controller to the metadata" do
      group = RSpec::Core::ExampleGroup.describe do
        include ControllerExampleGroup
      end
      group.metadata[:type].should eq(:controller)
    end
  end
end
