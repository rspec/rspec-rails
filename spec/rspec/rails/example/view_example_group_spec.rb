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
        include ViewExampleGroupBehaviour
      end.new
    end

    let(:helpers) { double("helpers").as_null_object }
    let(:example) { double("example").as_null_object }

    before do
      helpers.stub(:include?) { false }
      view_spec.stub(:helpers) { helpers }
      view_spec.stub(:running_example) { example }
    end

    context "given no input" do
      it "sends render(:file => (described file)) to the view" do
        view_spec.stub(:file_to_render) { "widgets/new.html.erb" }
        view_spec.view.should_receive(:render).
          with({:file => "widgets/new.html.erb"}, {})
        view_spec.render
      end
    end

    context "given a string" do
      it "sends :file => string as the first arg to render" do
        view_spec.view.should_receive(:render).
          with({:file => 'arbitrary/path'}, {})
        view_spec.render('arbitrary/path')
      end
    end

    context "given a hash" do
      it "sends the hash as the first arg to render" do
        pending
        view_spec.view.should_receive(:render).
          with({:foo => 'bar'}, {})
        view_spec.render(:foo => 'bar')
      end
    end
  end
end
