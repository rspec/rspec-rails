# Generators are not automatically loaded by Rails
require 'generators/rspec/observer/observer_generator'
require 'support/generators'

RSpec.describe Rspec::Generators::ObserverGenerator, :type => :generator do
  setup_default_destination

  subject { file('spec/models/posts_observer_spec.rb') }

  before do
    run_generator %w(posts)
  end

  describe 'the spec' do
    it { is_expected.to exist }
    it { is_expected.to contain(/require 'rails_helper'/) }
    it { is_expected.to contain(/^RSpec.describe PostsObserver, #{type_metatag(:observer)}/) }
  end
end
