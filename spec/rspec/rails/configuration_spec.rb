require "spec_helper"

describe "configuration" do
  before do
    @orig_render_views = RSpec.configuration.render_views?
  end

  after do
    RSpec.configuration.render_views = @orig_render_views
  end

  describe "#render_views?" do
    it "is false by default" do
      expect(RSpec.configuration.render_views?).to be_falsey
    end
  end

  describe "#render_views" do
    it "sets render_views? to return true" do
      RSpec.configuration.render_views = false
      RSpec.configuration.render_views

      expect(RSpec.configuration.render_views?).to be_truthy
    end
  end
end
