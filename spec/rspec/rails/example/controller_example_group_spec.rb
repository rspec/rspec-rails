require "spec_helper"

class ::ApplicationController
  def self.abstract?; false; end
end

module RSpec::Rails
  describe ControllerExampleGroup do
    it { is_expected.to be_included_in_files_in('./spec/controllers/') }
    it { is_expected.to be_included_in_files_in('.\\spec\\controllers\\') }

    let(:group) do
      RSpec::Core::ExampleGroup.describe do
        include ControllerExampleGroup
      end
    end

    it "includes routing matchers" do
      expect(group.included_modules).to include(RSpec::Rails::Matchers::RoutingMatchers)
    end

    it "adds :type => :controller to the metadata" do
      expect(group.metadata[:type]).to eq(:controller)
    end

    context "with implicit subject" do
      it "uses the controller as the subject" do
        controller = double('controller')
        example = group.new
        allow(example).to receive_messages(:controller => controller)
        expect(example.subject).to eq(controller)
      end
    end

    context "with explicit subject" do
      it "uses the specified subject instead of the controller" do
        group.subject { 'explicit' }
        example = group.new
        expect(example.subject).to eq('explicit')
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
        allow(controller).to receive(:foos_url).and_return('http://test.host/foos')

        example = group.new
        allow(example).to receive_messages(:controller => controller)

        # As in the routing example spec, this is pretty invasive, but not sure
        # how to do it any other way as the correct operation relies on before
        # hooks
        routes = ActionDispatch::Routing::RouteSet.new
        routes.draw { resources :foos }
        example.instance_variable_set(:@orig_routes, routes)

        expect(example.foos_url).to eq('http://test.host/foos')
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
        allow(group).to receive(:controller_class).and_return(Class.new)
      end

      it "defaults to inferring anonymous controller class" do
        expect(RSpec.configuration.infer_base_class_for_anonymous_controllers).to be_truthy
      end

      context "when infer_base_class_for_anonymous_controllers is true" do
        before do
          allow(RSpec.configuration).to receive(:infer_base_class_for_anonymous_controllers?).and_return(true)
        end

        it "infers the anonymous controller class" do
          group.controller { }

          controller_class = group.metadata[:example_group][:described_class]
          expect(controller_class.superclass).to eq(group.controller_class)
        end

        it "infers the anonymous controller class when no ApplicationController is present" do
          hide_const '::ApplicationController'
          group.controller { }

          controller_class = group.metadata[:example_group][:described_class]
          expect(controller_class.superclass).to eq(group.controller_class)
        end
      end

      context "when infer_base_class_for_anonymous_controllers is false" do
        before do
          allow(RSpec.configuration).to receive(:infer_base_class_for_anonymous_controllers?).and_return(false)
        end

        it "sets the anonymous controller class to ApplicationController" do
          group.controller { }

          controller_class = group.metadata[:example_group][:described_class]
          expect(controller_class.superclass).to eq(ApplicationController)
        end

        it "sets the anonymous controller class to ActiveController::Base when no ApplicationController is present" do
          hide_const '::ApplicationController'
          group.controller { }

          controller_class = group.metadata[:example_group][:described_class]
          expect(controller_class.superclass).to eq(ActionController::Base)
        end
      end
    end

    describe "controller name" do
      let(:controller_class) { group.metadata[:example_group][:described_class] }

      it "sets the name as AnonymousController if it's anonymous" do
        group.controller { }
        expect(controller_class.name).to eq "AnonymousController"
      end

      it "sets the name according to defined controller if it is not anonymous" do
        stub_const "FoosController", Class.new(::ApplicationController)
        group.controller(FoosController) { }
        expect(controller_class.name).to eq "FoosController"
      end

      it "sets name as AnonymousController if defined as ApplicationController" do
        group.controller(ApplicationController) { }
        expect(controller_class.name).to eq "AnonymousController"
      end

      it "sets name as AnonymousController the controller is abstract" do
        abstract_controller = Class.new(::ApplicationController)
        def abstract_controller.abstract?; true; end

        group.controller(abstract_controller) { }
        expect(controller_class.name).to eq "AnonymousController"
      end
    end
  end
end
