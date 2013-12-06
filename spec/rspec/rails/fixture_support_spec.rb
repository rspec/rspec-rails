require "spec_helper"

module RSpec::Rails
  describe FixtureSupport do
    context "with use_transactional_fixtures set to false" do
      it "still supports fixture_path" do
        allow(RSpec.configuration).to receive(:use_transactional_fixtures) { false }
        group = RSpec::Core::ExampleGroup.describe do
          include FixtureSupport
        end

        expect(group).to respond_to(:fixture_path)
        expect(group).to respond_to(:fixture_path=)
      end
    end
  end
end
