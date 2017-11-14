# Generators are not automatically loaded by Rails
require 'generators/rspec/scaffold/scaffold_generator'
require 'support/generators'

RSpec.describe Rspec::Generators::ScaffoldGenerator, :type => :generator do
  setup_default_destination

  describe 'standard controller spec' do
    subject { file('spec/controllers/posts_controller_spec.rb') }

    describe 'with no options' do
      before { run_generator %w[posts] }
      it { is_expected.to contain(/require 'rails_helper'/) }
      it { is_expected.to contain(/^RSpec.describe PostsController, #{type_metatag(:controller)}/) }
      it { is_expected.to contain(/GET #new/) }
      it { is_expected.to contain(/"redirects to the created \w+"/) }
      it { is_expected.to contain(/display the 'new' template/) }
      it { is_expected.not_to contain(/"renders a JSON response with the new \w+"/) }
      it { is_expected.not_to contain(/"renders a JSON response with errors for the new \w+"/) }

      it { is_expected.to contain(/GET #edit/) }
      it { is_expected.to contain(/"redirects to the \w+"/) }
      it { is_expected.to contain(/display the 'edit' template/) }
      it { is_expected.not_to contain(/"renders a JSON response with the \w+"/) }
      it { is_expected.not_to contain(/"renders a JSON response with errors for the \w+"/) }

      it { is_expected.to contain(/"redirects to the \w+ list"/) }
    end

    describe 'with --no-controller_specs' do
      before { run_generator %w[posts --no-controller_specs] }
      it { is_expected.not_to exist }
    end

    describe 'with --api' do
      before { run_generator %w[posts --api] }
      it { is_expected.to contain(/require 'rails_helper'/) }
      it { is_expected.to contain(/^RSpec.describe PostsController, #{type_metatag(:controller)}/) }
      it { is_expected.not_to contain(/GET #new/) }
      it { is_expected.not_to contain(/"redirects to the created \w+"/) }
      it { is_expected.not_to contain(/display the 'new' template/) }
      it { is_expected.to contain(/"renders a JSON response with the new \w+"/) }
      it { is_expected.to contain(/"renders a JSON response with errors for the new \w+"/) }
      it { is_expected.not_to contain(/GET #edit/) }
      it { is_expected.not_to contain(/"redirects to the \w+"/) }
      it { is_expected.not_to contain(/display the 'edit' template/) }
      it { is_expected.to contain(/"renders a JSON response with the \w+"/) }
      it { is_expected.to contain(/"renders a JSON response with errors for the \w+"/) }

      it { is_expected.not_to contain(/"redirects to the \w+ list"/) }

    end
  end

  describe 'namespaced controller spec' do
    subject { file('spec/controllers/admin/posts_controller_spec.rb') }
    before  { run_generator %w[admin/posts] }
    it { is_expected.to contain(/^RSpec.describe Admin::PostsController, #{type_metatag(:controller)}/) }
  end

  describe 'view specs' do
    describe 'with no options' do
      before { run_generator %w[posts] }

      describe 'edit' do
        subject { file("spec/views/posts/edit.html.erb_spec.rb") }
        it { is_expected.to exist }
        it { is_expected.to contain(/require 'rails_helper'/) }
        it { is_expected.to contain(/^RSpec.describe "(.*)\/edit", #{type_metatag(:view)}/) }
        it { is_expected.to contain(/it "renders the edit (.*) form"/) }
      end

      describe 'index' do
        subject { file("spec/views/posts/index.html.erb_spec.rb") }
        it { is_expected.to exist }
        it { is_expected.to contain(/require 'rails_helper'/) }
        it { is_expected.to contain(/^RSpec.describe "(.*)\/index", #{type_metatag(:view)}/) }
        it { is_expected.to contain(/it "renders a list of (.*)"/) }
      end

      describe 'new' do
        subject { file("spec/views/posts/new.html.erb_spec.rb") }
        it { is_expected.to exist }
        it { is_expected.to contain(/require 'rails_helper'/) }
        it { is_expected.to contain(/^RSpec.describe "(.*)\/new", #{type_metatag(:view)}/) }
        it { is_expected.to contain(/it "renders new (.*) form"/) }
      end

      describe 'show' do
        subject { file("spec/views/posts/show.html.erb_spec.rb") }
        it { is_expected.to exist }
        it { is_expected.to contain(/require 'rails_helper'/) }
        it { is_expected.to contain(/^RSpec.describe "(.*)\/show", #{type_metatag(:view)}/) }
        it { is_expected.to contain(/it "renders attributes in <p>"/) }
      end
    end

    describe 'with multiple integer attributes index' do
      before { run_generator %w[posts upvotes:integer downvotes:integer] }
      subject { file("spec/views/posts/index.html.erb_spec.rb") }
      it { is_expected.to exist }
      it { is_expected.to contain('assert_select "tr>td", :text => 2.to_s, :count => 2') }
      it { is_expected.to contain('assert_select "tr>td", :text => 3.to_s, :count => 2') }
    end

    describe 'with multiple float attributes index' do
      before { run_generator %w[posts upvotes:float downvotes:float] }
      subject { file("spec/views/posts/index.html.erb_spec.rb") }
      it { is_expected.to exist }
      it { is_expected.to contain('assert_select "tr>td", :text => 2.5.to_s, :count => 2') }
      it { is_expected.to contain('assert_select "tr>td", :text => 3.5.to_s, :count => 2') }
    end

    case
    when Rails.version.to_f >= 5.1
      describe 'with reference attribute' do
        before { run_generator %w[posts title:string author:references] }
        describe 'edit' do
          subject { file("spec/views/posts/edit.html.erb_spec.rb") }
          it { is_expected.to contain(/assert_select "input\[name=\?\]", "post\[author_id\]/) }
          it { is_expected.to contain(/assert_select "input\[name=\?\]", "post\[title\]/) }
        end

        describe 'new' do
          subject { file("spec/views/posts/new.html.erb_spec.rb") }
          it { is_expected.to contain(/assert_select "input\[name=\?\]", "post\[author_id\]"/) }
          it { is_expected.to contain(/assert_select "input\[name=\?\]", "post\[title\]/) }
        end
      end
    when Rails.version.to_f >= 4.0
      describe 'with reference attribute' do
        before { run_generator %w[posts title:string author:references] }
        describe 'edit' do
          subject { file("spec/views/posts/edit.html.erb_spec.rb") }
          it { is_expected.to contain(/assert_select "input#(.*)_author_id\[name=\?\]", "\1\[author_id\]/) }
          it { is_expected.to contain(/assert_select "input#(.*)_title\[name=\?\]", "\1\[title\]/) }
        end

        describe 'new' do
          subject { file("spec/views/posts/new.html.erb_spec.rb") }
          it { is_expected.to contain(/assert_select "input#(.*)_author_id\[name=\?\]", "\1\[author_id\]"/) }
          it { is_expected.to contain(/assert_select "input#(.*)_title\[name=\?\]", "\1\[title\]/) }
        end
      end
    end

    describe 'with --no-template-engine' do
      before { run_generator %w[posts --no-template-engine] }
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

    describe 'with --api' do
      before { run_generator %w[posts --api] }

      describe 'edit' do
        subject { file("spec/views/posts/edit.html.erb_spec.rb") }
        it { is_expected.not_to exist }
      end

      describe 'index' do
        subject { file("spec/views/posts/index.html.erb_spec.rb") }
        it { is_expected.not_to exist }
      end

      describe 'new' do
        subject { file("spec/views/posts/index.html.erb_spec.rb") }
        it { is_expected.not_to exist }
      end

      describe 'show' do
        subject { file("spec/views/posts/index.html.erb_spec.rb") }
        it { is_expected.not_to exist }
      end
    end

    describe 'with --no-view-specs' do
      before { run_generator %w[posts --no-view-specs] }

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
      before { run_generator %w[posts] }
      it { is_expected.to contain(/require "rails_helper"/) }
      it { is_expected.to contain(/^RSpec.describe PostsController, #{type_metatag(:routing)}/) }
      it { is_expected.to contain(/describe "routing"/) }
      it { is_expected.to contain(/routes to #new/) }
      it { is_expected.to contain(/routes to #edit/) }
    end

    describe 'with --no-routing-specs' do
      before { run_generator %w[posts --no-routing_specs] }
      it { is_expected.not_to exist }
    end

    describe 'with --api' do
      before { run_generator %w[posts --api] }
      it { is_expected.not_to contain(/routes to #new/) }
      it { is_expected.not_to contain(/routes to #edit/) }
    end
  end
end
