require 'generators/rspec/generator/generator_generator'
require 'support/generators'

RSpec.describe Rspec::Generators::GeneratorGenerator, type: :generator do
  setup_default_destination

  describe "generator specs" do
    subject(:generator_spec) { file("spec/generator/posts_generator_spec.rb") }
    before do
      run_generator %w[posts]
    end

    it "include the standard boilerplate" do
      expect(generator_spec).to contain(/require 'rails_helper'/).and(contain(/^RSpec.describe "PostsGenerator", #{type_metatag(:generator)}/))
    end
  end
end
