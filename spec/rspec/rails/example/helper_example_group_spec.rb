require "spec_helper"

module RSpec::Rails
  describe HelperExampleGroup do
    module ::FoosHelper; end

    subject { HelperExampleGroup }

    it_behaves_like "an rspec-rails example group mixin", :helper,
      './spec/helpers/', '.\\spec\\helpers\\'

    context "ActionView::TestCase::Behavior" do
      subject do
        group = RSpec::Core::ExampleGroup.describe ::FoosHelper do
          include HelperExampleGroup
        end
        group.new
      end

      it "mixes in ActionView::TestCase::Behavior" do
        expect(subject).to be_an(ActionView::TestCase::Behavior)
      end
    end

    describe "#controller_class" do
      subject do
        group = RSpec::Core::ExampleGroup.describe ::FoosHelper do
          include HelperExampleGroup
        end
        group.new.controller_class
      end

      context "only ActionController::Base exists" do
        it "returns the class" do
          hide_const("::ApplicationController")
          hide_const("::FoosController")
          expect(subject).to eq(ActionController::Base)
        end
      end

      context "ApplicationController exists" do
        before do
          stub_const("::ApplicationController", :ApplicationController)
        end

        it "returns the class" do
          expect(subject).to eq(:ApplicationController)
        end
      end

      context "ApplicationController subclass exists" do
        before do
          stub_const("::FoosController", :FoosController)
        end

        it "returns the class" do
          expect(subject).to eq(:FoosController)
        end
      end
    end

    describe "#controller" do
      before do
        dummy = double
        allow(dummy).to receive(:new).and_return(:new_instance)
        stub_const("::ApplicationController", dummy)
      end

      subject do
        group = RSpec::Core::ExampleGroup.describe ::FoosHelper do
          include HelperExampleGroup
        end
        group.new.controller
      end

      it "returns an instance of the controller class" do
        expect(subject).to eq(:new_instance)
      end
    end

    describe "#helper" do
      before do
        hide_const("::ApplicationController")
      end

      subject do
        group = RSpec::Core::ExampleGroup.describe ::FoosHelper do
          include HelperExampleGroup
        end
        group.new.helper
      end

      it "returns a view context associated with the controller" do
        expect(subject).to be_an(ActionView::Base)
        expect(subject.controller).to be_an(ActionController::Base)
      end

      it "returns a view context extended with the described helper module" do
        expect(subject).to be_a(FoosHelper)
      end

      context "ApplicationHelper exists" do
        let!(:application_helper) { Module.new }

        before { stub_const("ApplicationHelper", application_helper) }

        it "returns a view context extended with the ApplicationHelper" do
          expect(subject).to be_an(application_helper)
        end

        it "does not override the described module's methods" do
          singleton_class = (class << subject; self; end)
          higher_priority_mixin = singleton_class.ancestors.find do |ancestor|
            ancestor == FoosHelper || ancestor == application_helper
          end
          expect(higher_priority_mixin).to eq(FoosHelper)
        end
      end
    end

    describe "#subject" do
      before do
        hide_const("::ApplicationController")
      end

      subject do
        group = RSpec::Core::ExampleGroup.describe ::FoosHelper do
          include HelperExampleGroup
        end
        group.new
      end

      it "is #helper by default" do
        expect(subject.subject).to equal(subject.helper)
      end
    end

    describe "#assign" do
      before do
        hide_const("::ApplicationController")
      end

      subject do
        group = RSpec::Core::ExampleGroup.describe ::FoosHelper do
          include HelperExampleGroup
        end
        group.new
      end

      it "sets the given instance variable on the controller and the view context" do
        subject.assign(:foo, "bar")
        expect(subject.controller.instance_variable_get(:@foo)).to eq("bar")
        expect(subject.helper.instance_variable_get(:@foo)).to eq("bar")
      end
    end
  end
end
