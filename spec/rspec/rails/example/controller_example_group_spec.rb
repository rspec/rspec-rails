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

    it "should use the controller as the implicit subject" do
      group = RSpec::Core::ExampleGroup.describe do
        include ControllerExampleGroup
      end

      example = group.new

      controller = double('controller')
      example.stub(:controller => controller)

      example.subject.should == controller
    end

    describe "with a specified subject" do
      before do
        @group = RSpec::Core::ExampleGroup.describe do
          include ControllerExampleGroup
          subject { 'specified' }
        end
      end

      it "should use the specified subject instead of the controller" do
        example = @group.new
        example.subject.should == 'specified'
      end
    end
  end
end
