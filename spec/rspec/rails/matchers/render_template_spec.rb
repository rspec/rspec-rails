require "spec_helper"

describe "render_template" do
  context "given a hash" do
    it "delegates to assert_template" do
      self.should_receive(:assert_template).with({:this => "hash"}, "this message")
      "response".should render_template({:this => "hash"}, "this message")
    end
  end

  context "given a string" do
    it "delegates to assert_template" do
      self.should_receive(:assert_template).with("this string", "this message")
      "response".should render_template("this string", "this message")
    end
  end

  context "given a string" do
    it "converts to_s and delegates to assert_template" do
      self.should_receive(:assert_template).with("template_name", "this message")
      "response".should render_template(:template_name, "this message")
    end
  end
end

