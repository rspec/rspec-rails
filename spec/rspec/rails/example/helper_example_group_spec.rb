require "spec_helper"

module RSpec::Rails
  describe HelperExampleGroup do
    module ::FoosHelper; end
    subject { HelperExampleGroup }

    it { is_expected.to be_included_in_files_in('./spec/helpers/') }
    it { is_expected.to be_included_in_files_in('.\\spec\\helpers\\') }

    it "provides a controller_path based on the helper module's name" do
      example = double
      example.stub_chain(:example_group, :described_class) { FoosHelper }

      helper_spec = Object.new.extend HelperExampleGroup
      expect(helper_spec.__send__(:_controller_path, example)).to eq("foos")
    end

    it "adds :type => :helper to the metadata" do
      group = RSpec::Core::ExampleGroup.describe do
        include HelperExampleGroup
      end
      expect(group.metadata[:type]).to eq(:helper)
    end

    describe "#helper" do
      it "returns the instance of AV::Base provided by AV::TC::Behavior" do
        helper_spec = Object.new.extend HelperExampleGroup
        expect(helper_spec).to receive(:view_assigns)
        av_tc_b_view = double('_view')
        expect(av_tc_b_view).to receive(:assign)
        allow(helper_spec).to receive(:_view) { av_tc_b_view }
        expect(helper_spec.helper).to eq(av_tc_b_view)
      end

      before do
        Object.const_set(:ApplicationHelper, Module.new)
      end

      after do
        Object.__send__(:remove_const, :ApplicationHelper)
      end

      it "includes ApplicationHelper" do
        group = RSpec::Core::ExampleGroup.describe do
          include HelperExampleGroup
          def _view
            ActionView::Base.new
          end
        end
        expect(group.new.helper).to be_kind_of(ApplicationHelper)
      end
    end
  end

  describe HelperExampleGroup::ClassMethods do
    describe "determine_default_helper_class" do
      it "returns the helper module passed to describe" do
        helper_spec = Object.new.extend HelperExampleGroup::ClassMethods
        allow(helper_spec).to receive(:described_class) { FoosHelper }
        expect(helper_spec.determine_default_helper_class("ignore this")).
          to eq(FoosHelper)
      end
    end
  end
end
