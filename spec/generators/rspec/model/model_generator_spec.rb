require 'spec_helper'

require 'generators/rspec/model/model_generator'

describe Rspec::Generators::ModelGenerator do
  it 'should run both the model and fixture tasks' do
    gen = generator %w(posts)
    gen.should_receive :create_model_spec
    gen.should_receive :create_fixture_file
    capture(:stdout) { gen.invoke_all }
  end
  
  describe 'creating model spec' do
    it 'should create a spec file from template' do
      gen = generator %w(posts), %w(--fixture true)
      gen.should_receive(:template).with('model_spec.rb', 'spec/models/posts_spec.rb')
      gen.create_model_spec
    end
  end

  describe 'creating fixtures' do
    it 'should create a fixture file when no fixture replacement specified' do
      gen = generator %w(posts), %w(--fixture true)
      gen.should_receive(:template).with('fixtures.yml', 'spec/fixtures/posts.yml')
      gen.create_fixture_file
    end
    it 'should not create a fixture file when told not to generate a fixture' do
      gen = generator %w(posts), %w(--fixture false)
      gen.should_not_receive(:template)
      gen.create_fixture_file
    end
    it 'should not create a fixture file when using fixture replacement' do
      gen = generator %w(posts), %w(--fixture true --fixture-replacement factory_girl)
      gen.should_not_receive(:template)
      gen.create_fixture_file
    end
  end
end
