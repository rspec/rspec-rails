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

  describe "#escaped_path" do
    specify "is deprecated" do
      expect_deprecation_with_call_site(__FILE__, __LINE__ + 1)
      RSpec.configuration.escaped_path
    end
  end
end
