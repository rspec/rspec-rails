# Generators are not automatically loaded by Rails
require 'generators/rspec/generator/generator_generator'
require 'support/generators'

RSpec.describe Rspec::Generators::GeneratorGenerator, :type => :generator do
  setup_default_destination

  describe 'generator specs' do
    describe 'not namespaced' do
      before do
        run_generator %w(awesome)
      end

      subject { file('spec/lib/generators/awesome_generator_spec.rb') }

      describe 'the spec' do
        it { is_expected.to exist }
        it { is_expected.to contain(/require 'rails_helper'/) }
        it { is_expected.to contain(/require 'generators\/awesome\/awesome_generator'/) }
        it { is_expected.to contain(/^RSpec.describe AwesomeGenerator, #{type_metatag(:generator)}/) }
      end
    end

    describe 'namespaced' do
      before do
        run_generator %w(wonderful/awesome)
      end

      subject { file('spec/lib/generators/wonderful/awesome_generator_spec.rb') }

      describe 'the spec' do
        it { is_expected.to exist }
        it { is_expected.to contain(/require 'rails_helper'/) }
        it { is_expected.to contain(/require 'generators\/wonderful\/awesome\/awesome_generator'/) }
        it { is_expected.to contain(/^RSpec.describe Wonderful::AwesomeGenerator, #{type_metatag(:generator)}/) }
      end
    end
  end
end
