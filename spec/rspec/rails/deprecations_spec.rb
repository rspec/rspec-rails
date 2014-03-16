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
        allow(RSpec).to receive(:deprecate)
        group.integrate_views
        expect(RSpec).to have_received(:deprecate).with(/integrate_views/, anything)
      end
    end
  end
end
