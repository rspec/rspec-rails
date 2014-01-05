require 'spec_helper'

describe "rspec-rails-2 deprecations" do
  context "controller specs" do
    describe "::integrate_views" do
      let(:group) do
        RSpec::Core::ExampleGroup.describe do
          include RSpec::Rails::ControllerExampleGroup
        end
      end

      it "is deprecated" do
        expect(RSpec).to receive(:deprecate)
        group.integrate_views
      end
    end
  end

  context "activemodel mocking" do
    describe "mock_model" do
      let(:model_class) { NonActiveRecordModel }
      it "is deprecated" do
        expect(RSpec).to receive(:deprecate)
        mock_model(model_class)
      end
    end

    describe "stub_model" do
     let(:model_class) { MockableModel }
     it "is deprecated" do
        expect(RSpec).to receive(:deprecate)
        stub_model(model_class)
      end
    end
  end
end
