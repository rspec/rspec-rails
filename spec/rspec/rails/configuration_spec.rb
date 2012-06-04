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
      RSpec.configuration.render_views?.should be_false
    end
  end

  describe "#render_views" do
    it "sets render_views? to return true" do
      RSpec.configuration.render_views = false
      RSpec.configuration.render_views

      RSpec.configuration.render_views?.should be_true
    end
  end

  describe "#application" do

    context "default" do

      it "is Rails.application by default" do
        RSpec.configuration.application.should eq(::Rails.application)
      end

    end

    context "custom rack application", :at_least_rails_3_1 do
      before do
        @orig_application = RSpec.configuration.application
      end

      after do
        RSpec.configuration.application = @orig_application
      end

      it "allows for custom application" do
        RSpec.configuration.application = RSpec::EngineExample
        RSpec.configuration.application.should eq(RSpec::EngineExample)
      end

    end
  end
end
