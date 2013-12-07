require 'spec_helper'

# Generators are not automatically loaded by rails
require 'generators/rspec/feature/feature_generator'

describe Rspec::Generators::FeatureGenerator do
  # Tell the generator where to put its output (what it thinks of as Rails.root)
  destination File.expand_path("../../../../../temp", __FILE__)

  before { prepare_destination } 

  describe 'feature specs' do
    describe 'are generated independently from the command line' do
      before do
        run_generator %w(posts)
      end
      describe 'the spec' do
        subject(:feature_spec) { file('spec/features/posts_spec.rb') }
        it "exists" do
          expect(feature_spec).to exist
        end
        it "contains 'spec_helper'" do
          expect(feature_spec).to contain(/require 'spec_helper'/)
        end
        it "contains the feature" do
          expect(feature_spec).to contain(/feature "Posts"/)
        end
      end
    end

    describe "are not generated" do
      before do
        run_generator %w(posts --no-feature-specs)
      end
      describe "the spec" do
        subject(:feature_spec) { file('spec/features/posts_spec.rb') }
        it "does not exist" do
          expect(feature_spec).to_not exist
        end
      end
    end
  end
end
