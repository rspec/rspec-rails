# Generators are not automatically loaded by Rails
require 'generators/rspec/model/model_generator'
require 'support/generators'

RSpec.describe Rspec::Generators::ModelGenerator, :type => :generator do
  setup_default_destination

  it 'runs both the model and fixture tasks' do
    gen = generator %w(posts)
    expect(gen).to receive :create_model_spec
    expect(gen).to receive :create_fixture_file
    gen.invoke_all
  end

  describe 'the generated files' do
    describe 'with fixtures' do
      before do
        run_generator %w(posts --fixture)
      end

      describe 'the spec' do
        subject { file('spec/models/posts_spec.rb') }

        it { is_expected.to exist }
        it { is_expected.to contain(/require 'rails_helper'/) }
        it { is_expected.to contain(/^RSpec.describe Posts, #{type_metatag(:model)}/) }
      end

      describe 'the fixtures' do
        subject { file('spec/fixtures/posts.yml') }

        it { is_expected.to contain(Regexp.new('# Read about fixtures at http://api.rubyonrails.org/classes/ActiveRecord/FixtureSet.html')) }
      end
    end

    describe 'without fixtures' do
      before do
        run_generator %w(posts)
      end

      describe 'the fixtures' do
        subject { file('spec/fixtures/posts.yml') }

        it { is_expected.not_to exist }
      end
    end
  end
end
