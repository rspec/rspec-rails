require 'spec_helper'

require 'generators/rspec/scaffold/scaffold_generator'

describe Rspec::Generators::ScaffoldGenerator do
  destination File.expand_path("../../../../../tmp", __FILE__)

  before { prepare_destination }

  describe 'standard controller spec' do
    subject { file('spec/controllers/posts_controller_spec.rb') }

    describe 'with no options' do
      before { run_generator %w(posts) }
      it { should contain(/require 'spec_helper'/) }
      it { should contain(/describe PostsController/) }
      it { should contain(%({ "these" => "params" })) }
    end

    describe 'with --no-controller_specs' do
      before { run_generator %w(posts --no-controller_specs) }
      it { should_not exist }
    end
  end

  describe 'controller spec with attributes specified' do
    subject { file('spec/controllers/posts_controller_spec.rb') }
    before { run_generator %w(posts title:string) }

    it { should contain(%({ "title" => "MyString" })) }
  end

  describe 'namespaced controller spec' do
    subject { file('spec/controllers/admin/posts_controller_spec.rb') }
    before  { run_generator %w(admin/posts) }
    it { should contain(/describe Admin::PostsController/)}
  end

  describe 'view specs' do
    describe 'with no options' do
      before { run_generator %w(posts) }
      describe 'edit' do
        subject { file("spec/views/posts/edit.html.erb_spec.rb") }
        it { should exist }
        it { should contain(/require 'spec_helper'/) }
        it { should contain(/describe "(.*)\/edit"/) }
        it { should contain(/it "renders the edit (.*) form"/) }
      end

      describe 'index' do
        subject { file("spec/views/posts/index.html.erb_spec.rb") }
        it { should exist }
        it { should contain(/require 'spec_helper'/) }
        it { should contain(/describe "(.*)\/index"/) }
        it { should contain(/it "renders a list of (.*)"/) }
      end

      describe 'new' do
        subject { file("spec/views/posts/new.html.erb_spec.rb") }
        it { should exist }
        it { should contain(/require 'spec_helper'/) }
        it { should contain(/describe "(.*)\/new"/) }
        it { should contain(/it "renders new (.*) form"/) }
      end

      describe 'show' do
        subject { file("spec/views/posts/show.html.erb_spec.rb") }
        it { should exist }
        it { should contain(/require 'spec_helper'/) }
        it { should contain(/describe "(.*)\/show"/) }
        it { should contain(/it "renders attributes in <p>"/) }
      end
    end

    describe 'with --no-view-specs' do
      before { run_generator %w(posts --no-view-specs) }

      describe 'edit' do
        subject { file("spec/views/posts/edit.html.erb_spec.rb") }
        it { should_not exist }
      end

      describe 'index' do
        subject { file("spec/views/posts/index.html.erb_spec.rb") }
        it { should_not exist }
      end

      describe 'new' do
        subject { file("spec/views/posts/new.html.erb_spec.rb") }
        it { should_not exist }
      end

      describe 'show' do
        subject { file("spec/views/posts/show.html.erb_spec.rb") }
        it { should_not exist }
      end
    end
  end

  describe 'routing spec' do
    subject { file('spec/routing/posts_routing_spec.rb') }

    describe 'with default options' do
      before { run_generator %w(posts) }
      it { should contain(/require "spec_helper"/) }
      it { should contain(/describe PostsController/) }
      it { should contain(/describe "routing"/) }
    end

    describe 'with --no-routing-specs' do
      before { run_generator %w(posts --no-routing_specs) }
      it { should_not exist }
    end
  end
end
