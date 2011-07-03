require 'spec_helper'

# Generators are not automatically loaded by Rails
require 'generators/rspec/view/view_generator'

describe Rspec::Generators::ViewGenerator do
  # Tell the generator where to put its output (what it thinks of as Rails.root)
  destination File.expand_path("../../../../../tmp", __FILE__)

  before { prepare_destination }

  describe 'with default template engine' do
    it 'generates a spec for the supplied action' do
      run_generator %w(posts index)
      file('spec/views/posts/index.html.erb_spec.rb').tap do |f|
        f.should contain /require 'spec_helper'/
        f.should contain /describe "posts\/index.html.erb"/
      end
    end

    describe 'with a nested resource' do
      it 'generates a spec for the supplied action' do
        run_generator %w(admin/posts index)
        file('spec/views/admin/posts/index.html.erb_spec.rb').tap do |f|
          f.should contain /require 'spec_helper'/
          f.should contain /describe "admin\/posts\/index.html.erb"/
        end
      end
    end
  end

  describe 'haml' do
    it 'generates a spec for the supplied action' do
      run_generator %w(posts index --template_engine haml)
      file('spec/views/posts/index.html.haml_spec.rb').tap do |f|
        f.should contain /require 'spec_helper'/
        f.should contain /describe "posts\/index.html.haml"/
      end
    end
  end
end
