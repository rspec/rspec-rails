require 'spec_helper'

# Generators are not automatically loaded by Rails
require 'generators/rspec/observer/observer_generator'

describe Rspec::Generators::ObserverGenerator do
  # Tell the generator where to put its output (what it thinks of as Rails.root)
  destination File.expand_path("../../../../../tmp", __FILE__)

  subject { file('spec/models/posts_observer_spec.rb') }
  before do
    prepare_destination
    run_generator %w(posts)
  end

  describe 'the spec' do
    it { should exist }
    it { should contain(/require 'spec_helper'/) }
    it { should contain(/describe PostsObserver/) }
  end
end
