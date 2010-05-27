require "spec_helper"

describe ViewExampleGroupBehaviour do
  it "is included in specs in ./spec/views" do
    stub_metadata(
      :example_group => {:file_path => "./spec/views/whatever_spec.rb:15"}
    )
    group = RSpec::Core::ExampleGroup.describe
    group.included_modules.should include(ViewExampleGroupBehaviour)
  end

  describe "#render" do
    let(:view_spec) do
      Class.new do
        module Local
          def received
            @received ||= []
          end
          def render(options={}, local_assigns={}, &block)
            received << [options, local_assigns, block]
          end
        end
        include Local
        include ViewExampleGroupBehaviour::InstanceMethods
      end.new
    end

    context "given no input" do
      it "sends render(:file => (described file)) to the view" do
        view_spec.stub(:_default_file_to_render) { "widgets/new.html.erb" }
        view_spec.render
        view_spec.received.first.should == [{:template => "widgets/new.html.erb"},{}, nil]
      end
    end

    context "given a string" do
      it "sends string as the first arg to render" do
        view_spec.render('arbitrary/path')
        view_spec.received.first.should == ["arbitrary/path", {}, nil]
      end
    end

    context "given a hash" do
      it "sends the hash as the first arg to render" do
        view_spec.render(:foo => 'bar')
        view_spec.received.first.should == [{:foo => "bar"}, {}, nil]
      end
    end
  end

  describe "#_controller_path" do
    let(:view_spec) do
      Class.new do
        include ViewExampleGroupBehaviour::InstanceMethods
      end.new
    end
    context "with a common _default_file_to_render" do
      it "it returns the directory" do
        view_spec.stub(:_default_file_to_render).
          and_return("things/new.html.erb")
        view_spec.__send__(:_controller_path).
          should == "things"
      end
    end

    context "with a nested _default_file_to_render" do
      it "it returns the directory path" do
        view_spec.stub(:_default_file_to_render).
          and_return("admin/things/new.html.erb")
        view_spec.__send__(:_controller_path).
          should == "admin/things"
      end
    end
  end
end
