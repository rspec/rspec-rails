require 'spec_helper'

require 'generators/rspec/model/model_generator'

describe Rspec::Generators::ModelGenerator do
  destination File.expand_path("../../../../../tmp", __FILE__)
  before do
    prepare_destination
  end

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
      invoke_task :create_model_spec
    end
  end

  describe 'creating fixtures' do
    it 'should create a fixture file when no fixture replacement specified' do
      gen = generator %w(posts), %w(--fixture true)
      gen.should_receive(:template).with('fixtures.yml', 'spec/fixtures/posts.yml')
      invoke_task :create_fixture_file
    end
    it 'should not create a fixture file when told not to generate a fixture' do
      gen = generator %w(posts), %w(--fixture false)
      gen.should_not_receive(:template)
      invoke_task :create_fixture_file
    end
    it 'should not create a fixture file when using fixture replacement' do
      gen = generator %w(posts), %w(--fixture true --fixture-replacement factory_girl)
      gen.should_not_receive(:template)
      invoke_task :create_fixture_file
    end
  end

  describe 'without mocking' do
    it 'should create model and fixture files' do
      run_generator %w(posts --fixture)
      file('spec/models/posts_spec.rb').should exist
      file('spec/models/posts_spec.rb').should contain /require 'spec_helper'/
      file('spec/models/posts_spec.rb').should contain /describe Posts/
    end
  end
end
