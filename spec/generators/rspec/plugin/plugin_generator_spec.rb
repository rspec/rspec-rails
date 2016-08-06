require 'spec_helper'

# Generators are not automatically loaded by Rails
require 'generators/rspec/plugin/plugin_generator'

describe Rspec::Generators::PluginGenerator do
  # Tell the generator where to put its output (what it thinks of as Rails.root)
  destination File.expand_path("../../../../../tmp", __FILE__)

  before { prepare_destination }

  describe 'with default template engine' do
    it 'generates a spec for the supplied action' do
      run_generator %w(plugin myplugin)
      file('spec/plugins/plugin_spec.rb').tap do |f|
        f.should contain(/require 'spec_helper'/)
        f.should contain(/describe Plugin/)
      end
    end
  end
end
