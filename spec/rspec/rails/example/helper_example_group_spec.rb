require "spec_helper"

describe HelperExampleGroupBehaviour do
  it "is included in specs in ./spec/views" do
    stub_metadata(
      :example_group => {:file_path => "./spec/helpers/whatever_spec.rb:15"}
    )
    group = RSpec::Core::ExampleGroup.describe
    group.included_modules.should include(HelperExampleGroupBehaviour)
  end

  module ::FoosHelper; end

  it "provides a controller_path based on the helper module's name" do
    helper_spec = Object.new
    helper_spec.extend HelperExampleGroupBehaviour::InstanceMethods
    helper_spec.stub_chain(:running_example, :example_group, :describes).and_return(FoosHelper)
    helper_spec.__send__(:_controller_path).should == "foos"
  end
end
