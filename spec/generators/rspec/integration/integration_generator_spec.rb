# Generators are not automatically loaded by Rails
require 'generators/rspec/integration/integration_generator'
require 'support/generators'
require 'rspec/core/warnings'

RSpec.describe Rspec::Generators::IntegrationGenerator, type: :generator do
  setup_default_destination
  it_behaves_like "a request spec generator"

  describe 'deprecation' do
    before do
      allow(RSpec).to receive(:warn_deprecation)
      run_generator %w[posts]
    end

    it "is deprecated" do
      expect(RSpec).to have_received(:warn_deprecation)
    end
  end
end
