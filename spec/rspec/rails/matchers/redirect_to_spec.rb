require "spec_helper"

describe "redirect_to" do
  it "delegates to assert_redirected_to" do
    self.should_receive(:assert_redirected_to).with("destination")
    "response".should redirect_to("destination")
  end
end
