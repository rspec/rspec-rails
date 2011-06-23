require 'spec_helper'

# Generators are not automatically loaded by Rails
require 'generators/rspec/install/install_generator'

describe Rspec::Generators::InstallGenerator do
  # Tell the generator where to put its output (what it thinks of as Rails.root)
  destination File.expand_path("../../../../../tmp", __FILE__)

  before do
    prepare_destination
    run_generator
  end
  describe '.rspec' do
    subject { file('.rspec') }
    it { should exist }
  end
  describe 'spec_helper.rb' do
    subject { file('spec/spec_helper.rb') }
    it { should exist }
  end
end
