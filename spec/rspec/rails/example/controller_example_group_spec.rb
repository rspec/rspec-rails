require "spec_helper"

class ::ApplicationController
end

module RSpec::Rails
  describe ControllerExampleGroup do
    it { is_expected.to be_included_in_files_in('./spec/controllers/') }
    it { is_expected.to be_included_in_files_in('.\\spec\\controllers\\') }

    def group_for(klass)
      RSpec::Core::ExampleGroup.describe klass, "more text" do
        include ControllerExampleGroup
      end
    end

    let(:group) { group_for ApplicationController }

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
        allow(example).to receive(:controller).and_return(controller)
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
        allow(example).to receive(:controller).and_return(controller)

        # As in the routing example spec, this is pretty invasive, but not sure
        #
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
      around { |ex| with_isolated_config(&ex) }
      let(:anonymous_klass) { Class.new }
      let(:group) { group_for(anonymous_klass) }

      it 'changes `described_class` so that it is equal to the new anonymous controller' do
        expect {
          group.controller { }
        }.to change { group.described_class }

        expect(group.described_class).to eq(group.metadata[:example_group][:described_class])
        expect(group.described_class).to eq(group.controller_class)
      end

      it 'issues a deprecation warning when `described_class` is accessed since the behavior is changing in RSpec 3' do
        group.controller { }
        expect_warn_deprecation_with_call_site(__FILE__, __LINE__ + 1, /described_class/)
        group.described_class
      end

      it 'issues a deprecation warning when `described_class` is accessed since the behavior is changing in RSpec 3' do
        group.controller { }
        expect_warn_deprecation_with_call_site(__FILE__, __LINE__ + 1, /described_class/)
        group.metadata[:example_group][:described_class]
      end

      it 'warns of `described_class` even if it was previously accessed' do
        group.described_class
        group.controller { }
        expect_warn_deprecation_with_call_site(__FILE__, __LINE__ + 1, /described_class/)
        group.described_class
      end

      it 'does not issue a deprecation warning when `controller_class`, `controller` or `subject` are accessed' do
        expect_no_deprecation
        group.controller { }

        group.controller_class
        example = group.new
        example.controller
        example.subject
      end

      it 'does not interfere with the metadata lazy-loading other values' do
        expect(group.metadata[:example_group]).not_to include(:full_description)
        group.controller { }
        expect(group.metadata[:example_group][:full_description]).to end_with("more text")
      end

      context "when infer_base_class_for_anonymous_controllers is true" do
        before do
          RSpec.configuration.infer_base_class_for_anonymous_controllers = true
        end

        it "infers the anonymous controller class" do
          group.controller { }
          expect(group.controller_class.superclass).to eq(anonymous_klass)
        end

        it "infers the anonymous controller class when no ApplicationController is present" do
          hide_const '::ApplicationController'
          group.controller { }
          expect(group.controller_class.superclass).to eq(anonymous_klass)
        end
      end

      context "when infer_base_class_for_anonymous_controllers is false" do
        before do
          RSpec.configuration.infer_base_class_for_anonymous_controllers = false
        end

        it "sets the anonymous controller class to ApplicationController" do
          group.controller { }
          expect(group.controller_class.superclass).to eq(ApplicationController)
        end

        it "sets the anonymous controller class to ActiveController::Base when no ApplicationController is present" do
          hide_const '::ApplicationController'
          group.controller { }
          expect(group.controller_class.superclass).to eq(ActionController::Base)
        end
      end
    end
  end
end
