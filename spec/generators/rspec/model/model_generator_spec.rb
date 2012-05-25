require 'spec_helper'

# Generators are not automatically loaded by Rails
require 'generators/rspec/model/model_generator'

describe Rspec::Generators::ModelGenerator do
  # Tell the generator where to put its output (what it thinks of as Rails.root)
  destination File.expand_path("../../../../../tmp", __FILE__)

  before { prepare_destination }

  it 'should run both the model and fixture tasks' do
    gen = generator %w(posts)
    gen.should_receive :create_model_spec
    gen.should_receive :create_fixture_file
    capture(:stdout) { gen.invoke_all }
  end

  describe 'the generated files' do
    describe 'with fixtures' do
      before do
        run_generator %w(posts --fixture)
      end

      describe 'the spec' do
        subject { file('spec/models/posts_spec.rb') }

        it { should exist }
        it { should contain(/require 'spec_helper'/) }
        it { should contain(/describe Posts/) }
      end

      describe 'the fixtures' do
        subject { file('spec/fixtures/posts.yml') }

        it { should contain(Regexp.new('# Read about fixtures at http://api.rubyonrails.org/classes/ActiveRecord/Fixtures.html')) }
      end
    end

    describe 'without fixtures' do
      before do
        run_generator %w(posts)
      end

      describe 'the fixtures' do
        subject { file('spec/fixtures/posts.yml') }

        it { should_not exist }
      end
    end
  end
end
