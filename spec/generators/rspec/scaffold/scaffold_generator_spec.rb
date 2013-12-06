require 'spec_helper'

require 'generators/rspec/scaffold/scaffold_generator'

describe Rspec::Generators::ScaffoldGenerator do
  destination File.expand_path("../../../../../tmp", __FILE__)

  before { prepare_destination }

  describe 'standard controller spec' do
    subject { file('spec/controllers/posts_controller_spec.rb') }

    describe 'with no options' do
      before { run_generator %w(posts) }
      it { is_expected.to contain(/require 'spec_helper'/) }
      it { is_expected.to contain(/describe PostsController/) }
      it { is_expected.to contain(%({ "these" => "params" })) }
    end

    describe 'with --no-controller_specs' do
      before { run_generator %w(posts --no-controller_specs) }
      it { is_expected.not_to exist }
    end
  end

  describe 'controller spec with attributes specified' do
    subject { file('spec/controllers/posts_controller_spec.rb') }
    before { run_generator %w(posts title:string) }

    it { is_expected.to contain(%({ "title" => "MyString" })) }
  end

  describe 'namespaced controller spec' do
    subject { file('spec/controllers/admin/posts_controller_spec.rb') }
    before  { run_generator %w(admin/posts) }
    it { is_expected.to contain(/describe Admin::PostsController/)}
  end

  describe 'view specs' do
    describe 'with no options' do
      before { run_generator %w(posts) }
      describe 'edit' do
        subject { file("spec/views/posts/edit.html.erb_spec.rb") }
        it { is_expected.to exist }
        it { is_expected.to contain(/require 'spec_helper'/) }
        it { is_expected.to contain(/describe "(.*)\/edit"/) }
        it { is_expected.to contain(/it "renders the edit (.*) form"/) }
      end

      describe 'index' do
        subject { file("spec/views/posts/index.html.erb_spec.rb") }
        it { is_expected.to exist }
        it { is_expected.to contain(/require 'spec_helper'/) }
        it { is_expected.to contain(/describe "(.*)\/index"/) }
        it { is_expected.to contain(/it "renders a list of (.*)"/) }
      end

      describe 'new' do
        subject { file("spec/views/posts/new.html.erb_spec.rb") }
        it { is_expected.to exist }
        it { is_expected.to contain(/require 'spec_helper'/) }
        it { is_expected.to contain(/describe "(.*)\/new"/) }
        it { is_expected.to contain(/it "renders new (.*) form"/) }
      end

      describe 'show' do
        subject { file("spec/views/posts/show.html.erb_spec.rb") }
        it { is_expected.to exist }
        it { is_expected.to contain(/require 'spec_helper'/) }
        it { is_expected.to contain(/describe "(.*)\/show"/) }
        it { is_expected.to contain(/it "renders attributes in <p>"/) }
      end
    end

    describe 'with --no-template-engine' do
      before { run_generator %w(posts --no-template-engine) }
      describe 'edit' do
        subject { file("spec/views/posts/edit.html._spec.rb") }
        it { is_expected.not_to exist }
      end

      describe 'index' do
        subject { file("spec/views/posts/index.html._spec.rb") }
        it { is_expected.not_to exist }
      end

      describe 'new' do
        subject { file("spec/views/posts/new.html._spec.rb") }
        it { is_expected.not_to exist }
      end

      describe 'show' do
        subject { file("spec/views/posts/show.html._spec.rb") }
        it { is_expected.not_to exist }
      end
    end

    describe 'with --no-view-specs' do
      before { run_generator %w(posts --no-view-specs) }

      describe 'edit' do
        subject { file("spec/views/posts/edit.html.erb_spec.rb") }
        it { is_expected.not_to exist }
      end

      describe 'index' do
        subject { file("spec/views/posts/index.html.erb_spec.rb") }
        it { is_expected.not_to exist }
      end

      describe 'new' do
        subject { file("spec/views/posts/new.html.erb_spec.rb") }
        it { is_expected.not_to exist }
      end

      describe 'show' do
        subject { file("spec/views/posts/show.html.erb_spec.rb") }
        it { is_expected.not_to exist }
      end
    end
  end

  describe 'routing spec' do
    subject { file('spec/routing/posts_routing_spec.rb') }

    describe 'with default options' do
      before { run_generator %w(posts) }
      it { is_expected.to contain(/require "spec_helper"/) }
      it { is_expected.to contain(/describe PostsController/) }
      it { is_expected.to contain(/describe "routing"/) }
    end

    describe 'with --no-routing-specs' do
      before { run_generator %w(posts --no-routing_specs) }
      it { is_expected.not_to exist }
    end
  end
end
