# Generators are not automatically loaded by rails
require 'generators/rspec/system/system_generator'
require 'support/generators'

RSpec.describe Rspec::Generators::SystemGenerator, type: :generator do
  setup_default_destination

  describe "system specs" do
    subject(:system_spec) { file("spec/system/posts_spec.rb") }

    describe "are generated independently from the command line" do
      before do
        run_generator %w[posts]
      end

      describe "the spec" do
        it "contains the standard boilerplate" do
          expect(system_spec).to contain(/require 'rails_helper'/).and(contain(/^RSpec.describe "Posts", #{type_metatag(:system)}/))
        end
      end
    end

    describe "are not generated" do
      before do
        run_generator %w[posts --no-system-specs]
      end

      describe "the spec" do
        it "does not exist" do
          expect(File.exist?(system_spec)).to be false
        end
      end
    end
  end
end
