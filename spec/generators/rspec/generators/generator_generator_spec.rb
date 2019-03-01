require 'generators/rspec/generators/generator_generator'
require 'support/generators'

RSpec.describe Rspec::Generators::GeneratorsGenerator, :type => :generator do
  setup_default_destination

  describe "generator specs" do
    subject(:generator_spec) { file("spec/generator/posts_generator_spec.rb") }
    describe "are generated independently/can be generated" do
      before do
        run_generator %w(posts --generator-specs)
      end
      it "creates the spec file" do
        expect(generator_spec).to exist
      end
      it "contains 'rails_helper in the spec file'" do
        expect(generator_spec).to contain(/require 'rails_helper'/)
      end
      it "includes the generator type in the metadata" do
        expect(generator_spec).to contain(/^RSpec.describe \"Posts\", #{type_metatag(:generator)}/)
      end
    end

    describe "are not generated/are skipped by default" do
      before do
        run_generator %w(posts)
      end
      describe "the spec" do
        it "does not exist" do
          expect(generator_spec).to_not exist
        end
      end
    end
  end
end
