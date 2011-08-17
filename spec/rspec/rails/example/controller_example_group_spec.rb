require "spec_helper"

class ::ApplicationController
end

module RSpec::Rails
  describe ControllerExampleGroup do
    it { should be_included_in_files_in('./spec/controllers/') }
    it { should be_included_in_files_in('.\\spec\\controllers\\') }

    let(:group) do
      RSpec::Core::ExampleGroup.describe do
        include ControllerExampleGroup
      end
    end

    it "includes routing matchers" do
      group.included_modules.should include(RSpec::Rails::Matchers::RoutingMatchers)
    end

    it "adds :type => :controller to the metadata" do
      group.metadata[:type].should eq(:controller)
    end

    context "with implicit subject" do
      it "uses the controller as the subject" do
        controller = double('controller')
        example = group.new
        example.stub(:controller => controller)
        example.subject.should == controller
      end
    end

    context "with explicit subject" do
      it "uses the specified subject instead of the controller" do
        group.subject { 'explicit' }
        example = group.new
        example.subject.should == 'explicit'
      end
    end

    describe "#controller" do
      before do
        group.class_eval do
          controller(Class.new) { }
        end
      end

      it "delegates named route helpers to the underlying controller" do
        controller = double('controller')
        controller.stub(:foos_url).and_return('http://test.host/foos')

        example = group.new
        example.stub(:controller => controller)

        # As in the routing example spec, this is pretty invasive, but not sure
        # how to do it any other way as the correct operation relies on before
        # hooks
        routes = ActionDispatch::Routing::RouteSet.new
        routes.draw { resources :foos }
        example.instance_variable_set(:@orig_routes, routes)

        example.foos_url.should eq('http://test.host/foos')
      end
    end

    describe "#bypass_rescue" do
      it "overrides the rescue_with_handler method on the controller to raise submitted error" do
        example = group.new
        example.instance_variable_set("@controller", Class.new { def rescue_with_handler(e); end }.new)
        example.bypass_rescue
        expect do
          example.controller.rescue_with_handler(RuntimeError.new("foo"))
        end.to raise_error("foo")
      end
    end

    describe "with inferred anonymous controller" do
      before do
        group.stub(:controller_class).and_return(Class.new)
      end

      it "infers the anonymous controller class when infer_base_class_for_anonymous_controllers is true" do
        RSpec.configuration.stub(:infer_base_class_for_anonymous_controllers?).and_return(true)
        group.controller { }

        controller_class = group.metadata[:example_group][:describes]
        controller_class.superclass.should eq(group.controller_class)
      end

      it "sets the anonymous controller class to ApplicationController when infer_base_class_for_anonymous_controllers is false" do
        RSpec.configuration.stub(:infer_base_class_for_anonymous_controllers?).and_return(false)
        group.controller { }

        controller_class = group.metadata[:example_group][:describes]
        controller_class.superclass.should eq(ApplicationController)
      end
    end
  end
end
