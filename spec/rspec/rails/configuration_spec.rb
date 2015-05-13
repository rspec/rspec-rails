require "spec_helper"

RSpec.describe "Configuration" do

  subject(:config) { RSpec.configuration.clone }

  describe "#render_views?" do
    it "is false by default" do
      expect(config.render_views?).to be_falsey
    end
  end

  describe "#render_views" do
    it "sets render_views? to return true" do
      expect {
        config.render_views
      }.to change { config.render_views? }.to be_truthy
    end
  end
end
