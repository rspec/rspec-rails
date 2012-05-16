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
        if Gem::Version.new(Rails.version) >= Gem::Version.new('3.1.0')
          RSpec.configuration.application.should eq(::Rails.application)
        else
          expect { RSpec.configuration.application }.should raise_error
        end
      end

    end

    context "custom rack application" do
      before do
        if Gem::Version.new(Rails.version) >= Gem::Version.new('3.1.0')
          @orig_application = RSpec.configuration.application
        end
      end

      after do
        if Gem::Version.new(Rails.version) >= Gem::Version.new('3.1.0')
          RSpec.configuration.application = @orig_application
        end
      end

      it "allows for custom application" do
        if Gem::Version.new(Rails.version) >= Gem::Version.new('3.1.0')
          RSpec.configuration.application = RSpec::EngineExample
          RSpec.configuration.application.should eq(RSpec::EngineExample)
        else
          expect { RSpec.configuration.application = RSpec::EngineExample }.should raise_error
        end
      end

    end
  end
end
