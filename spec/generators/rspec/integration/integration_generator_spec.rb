require 'spec_helper'

# Generators are not automatically loaded by Rails
require 'generators/rspec/integration/integration_generator'

describe Rspec::Generators::IntegrationGenerator do
  # Tell the generator where to put its output (what it thinks of as Rails.root)
  destination File.expand_path("../../../../../tmp", __FILE__)

  before { prepare_destination }

  describe 'are not generated' do
    before do
      run_generator %w(posts --no-request-specs)
    end
    describe 'index.html.erb' do
      subject { file('spec/requests/posts_spec.rb') }
      it { is_expected.not_to exist }
    end
  end

  describe 'are generated' do
    before do
      run_generator %w(posts)
    end
    subject { file('spec/requests/posts_spec.rb') }
    it { is_expected.to exist }
    it { is_expected.to contain(/require 'spec_helper'/) }
    it { is_expected.to contain(/describe "GET \/posts"/) }
    it { is_expected.to contain(/get posts_index_path/) }
  end
end
