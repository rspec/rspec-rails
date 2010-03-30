require "spec_helper"

describe "render_template" do
  it "delegates to assert_template" do
    self.should_receive(:assert_template).with({:this => "hash"}, "this message")
    "response".should render_template({:this => "hash"}, "this message")
  end
end
