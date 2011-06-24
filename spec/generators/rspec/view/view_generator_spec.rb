require 'spec_helper'

# Generators are not automatically loaded by Rails
require 'generators/rspec/view/view_generator'

describe Rspec::Generators::ViewGenerator do
  # Tell the generator where to put its output (what it thinks of as Rails.root)
  destination File.expand_path("../../../../../tmp", __FILE__)

  before { prepare_destination }

  describe 'a spec is created for each action' do
    describe 'with default template engine' do
      before do
        run_generator %w(posts index show)
      end
      describe 'index.html.erb' do
        subject { file('spec/views/posts/index.html.erb_spec.rb') }
        it { should exist }
        it { should contain /require 'spec_helper'/ }
        it { should contain /describe "posts\/index.html.erb"/ }
      end
      describe 'show.html.erb' do
        subject { file('spec/views/posts/show.html.erb_spec.rb') }
        it { should exist }
        it { should contain /require 'spec_helper'/ }
        it { should contain /describe "posts\/show.html.erb"/ }
      end
    end
    describe 'with haml' do
      before do
        run_generator %w(posts index --template_engine haml)
      end
      describe 'index.html.haml' do
        subject { file('spec/views/posts/index.html.haml_spec.rb') }
        it { should exist }
        it { should contain /require 'spec_helper'/ }
        it { should contain /describe "posts\/index.html.haml"/ }
      end
    end
  end
end

