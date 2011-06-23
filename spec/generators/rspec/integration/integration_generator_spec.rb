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
      it { should_not exist }
    end
  end

  describe 'are generated' do
    describe 'without webrat matchers by default' do
      before do
        run_generator %w(posts)
      end
      subject { file('spec/requests/posts_spec.rb') }
      it { should exist }
      it { should contain /require 'spec_helper'/ }
      it { should contain /describe "GET \/posts"/ }
      it { should contain /get posts_index_path/ }
    end
    describe 'with webrat matchers' do
      before do
        run_generator %w(posts --webrat)
      end
      subject { file('spec/requests/posts_spec.rb') }
      it { should exist }
      it { should contain /require 'spec_helper'/ }
      it { should contain /describe "GET \/posts"/ }
      it { should contain /visit posts_index_path/ }
    end
  end
end
