require "spec_helper"

module RSpec::Rails
  describe HelperExampleGroup::InstanceMethods do
    module ::FoosHelper; end

    it "is included in specs in ./spec/views" do
      stub_metadata(
        :example_group => {:file_path => "./spec/helpers/whatever_spec.rb:15"}
      )
      group = RSpec::Core::ExampleGroup.describe
      group.included_modules.should include(HelperExampleGroup)
    end

    it "provides a controller_path based on the helper module's name" do
      helper_spec = Object.new.extend HelperExampleGroup::InstanceMethods
      helper_spec.stub_chain(:example, :example_group, :describes).and_return(FoosHelper)
      helper_spec.__send__(:_controller_path).should == "foos"
    end

    describe "#helper" do
      it "returns the instance of AV::Base provided by AV::TC::Behavior" do
        helper_spec = Object.new.extend HelperExampleGroup::InstanceMethods
        av_tc_b_view = double('_view')
        helper_spec.stub(:_view) { av_tc_b_view }
        helper_spec.helper.should eq(av_tc_b_view)
      end
    end
  end

  describe HelperExampleGroup::ClassMethods do
    describe "determine_default_helper_class" do
      it "returns the helper module passed to describe" do
        helper_spec = Object.new.extend HelperExampleGroup::ClassMethods
        helper_spec.stub(:describes) { FoosHelper }
        helper_spec.determine_default_helper_class("ignore this").
          should eq(FoosHelper)
      end
    end
  end
end
