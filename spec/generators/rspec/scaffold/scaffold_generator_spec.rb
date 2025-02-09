# Generators are not automatically loaded by Rails
require 'generators/rspec/scaffold/scaffold_generator'
require 'support/generators'
require 'rspec/support/spec/in_sub_process'

RSpec.describe Rspec::Generators::ScaffoldGenerator, type: :generator do
  include RSpec::Support::InSubProcess
  setup_default_destination

  describe 'standard request specs' do
    subject(:filename) { file('spec/requests/posts_spec.rb') }

    describe 'with no options' do
      before { run_generator %w[posts --request_specs] }

      it "includes the standard boilerplate" do
        expect(
          filename
        ).to(
          contain("require 'rails_helper'")
            .and(contain(/^RSpec.describe "\/posts", #{type_metatag(:request)}/))
            .and(contain('GET /new'))
            .and(contain(/"redirects to the created post"/))
            .and(contain('get post_url(post)'))
            .and(contain('redirect_to(post_url(Post.last))'))
            .and(contain(/"redirects to the \w+ list"/))
        )

        expect(
          filename
        ).to(
          contain(/renders a response with 422 status \(i.e. to display the 'new' template\)/)
            .and(contain(/renders a response with 422 status \(i.e. to display the 'edit' template\)/))
        )
      end
    end

    describe 'with --no-request_specs' do
      before { run_generator %w[posts --no-request_specs] }

      it "is skipped" do
        expect(File.exist?(filename)).to be false
      end
    end

    describe 'with --api' do
      before { run_generator %w[posts --api] }

      it "includes the standard boilerplate" do
        expect(
          filename
        ).to(
          contain(/require 'rails_helper'/)
            .and(contain(/^RSpec.describe "\/posts", #{type_metatag(:request)}/))
            .and(contain('as: :json'))
            .and(contain('renders a JSON response with the new post'))
            .and(contain('renders a JSON response with errors for the new post'))
            .and(contain('renders a JSON response with the post'))
            .and(contain('renders a JSON response with errors for the post'))
        )

        expect(filename).not_to contain('get new_posts_path')
        expect(filename).not_to contain(/"redirects to\w+"/)
        expect(filename).not_to contain('get edit_posts_path')
      end
    end

    describe 'in an engine' do
      it 'generates files with Engine url_helpers' do
        in_sub_process do
          allow_any_instance_of(::Rails::Generators::NamedBase).to receive(:mountable_engine?).and_return(true)
          run_generator %w[posts --request_specs]

          expect(filename).to contain('Engine.routes.url_helpers')
        end
      end
    end
  end

  describe 'standard controller spec' do
    subject(:filename) { file('spec/controllers/posts_controller_spec.rb') }

    describe 'with --controller_specs' do
      before { run_generator %w[posts --controller_specs] }

      it "includes the standard boilerplate" do
        expect(
          filename
        ).to(
          contain(/require 'rails_helper'/)
            .and(contain(/^RSpec.describe PostsController, #{type_metatag(:controller)}/))
            .and(contain(/GET #new/))
            .and(contain(/"redirects to the created \w+"/))
            .and(contain(/GET #edit/))
            .and(contain(/"redirects to the \w+"/))
            .and(contain(/"redirects to the \w+ list"/))
        )

        expect(filename).to contain(/renders a response with 422 status \(i.e. to display the 'new' template\)/)
                              .and(contain(/renders a response with 422 status \(i.e. to display the 'edit' template\)/))

        expect(filename).not_to contain(/"renders a JSON response with the new \w+"/)
        expect(filename).not_to contain(/"renders a JSON response with errors for the new \w+"/)
        expect(filename).not_to contain(/"renders a JSON response with the \w+"/)
        expect(filename).not_to contain(/"renders a JSON response with errors for the \w+"/)
      end
    end

    describe 'with no options' do
      before { run_generator %w[posts] }

      it 'skips the file' do
        expect(File.exist?(filename)).to be false
      end
    end

    describe 'with --api' do
      before { run_generator %w[posts --controller_specs --api] }

      it "includes the standard boilerplate" do
        expect(filename).to contain(/require 'rails_helper'/)
                             .and(contain(/^RSpec.describe PostsController, #{type_metatag(:controller)}/))
                             .and(contain(/"renders a JSON response with the new \w+"/))
                             .and(contain(/"renders a JSON response with errors for the new \w+"/))
                             .and(contain(/"renders a JSON response with the \w+"/))
                             .and(contain(/"renders a JSON response with errors for the \w+"/))

        expect(filename).not_to  contain(/GET #new/)
        expect(filename).not_to  contain(/"redirects to the created \w+"/)
        expect(filename).not_to  contain(/display the 'new' template/)
        expect(filename).not_to  contain(/GET #edit/)
        expect(filename).not_to  contain(/"redirects to the \w+"/)
        expect(filename).not_to  contain(/display the 'edit' template/)
        expect(filename).not_to  contain(/"redirects to the \w+ list"/)
      end
    end
  end

  describe 'namespaced request spec' do
    subject(:filename) { file('spec/requests/admin/posts_spec.rb') }

    describe 'with default options' do
      before { run_generator %w[admin/posts] }

      it "includes the standard boilerplate" do
        expect(filename).to contain(/^RSpec.describe "\/admin\/posts", #{type_metatag(:request)}/)
                           .and(contain('post admin_posts_url, params: { admin_post: valid_attributes }'))
                           .and(contain('admin_post_url(post)'))
                           .and(contain('Admin::Post.create'))
      end
    end

    describe 'with --model-name' do
      before { run_generator %w[admin/posts --model-name=post] }

      it "includes the standard boilerplate" do
        expect(filename).to contain('post admin_posts_url, params: { post: valid_attributes }')
                             .and(contain(' Post.create'))

        expect(filename).not_to contain('params: { admin_post: valid_attributes }')
      end
    end

    context 'with --api' do
      describe 'with default options' do
        before { run_generator %w[admin/posts --api] }

        it "includes the standard boilerplate" do
          expect(filename).to contain('params: { admin_post: valid_attributes }')
                               .and(contain('Admin::Post.create'))
        end
      end

      describe 'with --model-name' do
        before { run_generator %w[admin/posts --api --model-name=post] }

        it "includes the standard boilerplate" do
          expect(filename).to contain('params: { post: valid_attributes }')
                                .and(contain(' Post.create'))

          expect(filename).not_to contain('params: { admin_post: valid_attributes }')
        end
      end
    end
  end

  describe 'namespaced controller spec' do
    subject(:filename) { file('spec/controllers/admin/posts_controller_spec.rb') }

    describe 'with default options' do
      before { run_generator %w[admin/posts --controller_specs] }

      it "includes the standard boilerplate" do
        expect(filename).to contain(/^RSpec.describe Admin::PostsController, #{type_metatag(:controller)}/)
                             .and(contain('post :create, params: {admin_post: valid_attributes}'))
                             .and(contain('Admin::Post.create'))
      end
    end

    describe 'with --model-name' do
      before { run_generator %w[admin/posts --model-name=post --controller_specs] }

      it "includes the standard boilerplate" do
        expect(filename).to contain('post :create, params: {post: valid_attributes}')
                              .and(contain(' Post.create'))

        expect(filename).not_to contain('params: {admin_post: valid_attributes}')
      end
    end

    context 'with --api' do
      describe 'with default options' do
        before { run_generator %w[admin/posts --api --controller_specs] }

        it "includes the standard boilerplate" do
          expect(filename).to contain('post :create, params: {admin_post: valid_attributes}')
                                .and(contain('Admin::Post.create'))
        end
      end

      describe 'with --model-name' do
        before { run_generator %w[admin/posts --api --model-name=post --controller_specs] }

        it "includes the standard boilerplate" do
          expect(filename).to contain('post :create, params: {post: valid_attributes}')
                               .and(contain(' Post.create'))

          expect(filename).not_to contain('params: {admin_post: valid_attributes}')
        end
      end
    end
  end

  describe 'view specs' do
    describe 'with no options' do
      before { run_generator %w[posts] }

      describe 'edit' do
        subject(:filename) { file("spec/views/posts/edit.html.erb_spec.rb") }

        it "includes the standard boilerplate" do
          expect(filename).to contain(/require 'rails_helper'/)
                             .and(contain(/^RSpec.describe "(.*)\/edit", #{type_metatag(:view)}/))
                             .and(contain(/assign\(:post, post\)/))
                             .and(contain(/assert_select "form\[action=\?\]\[method=\?\]", post_path\(post\), "post" do/))
                             .and(contain(/it "renders the edit (.*) form"/))
        end
      end

      describe 'index' do
        subject(:filename) { file("spec/views/posts/index.html.erb_spec.rb") }

        it "includes the standard boilerplate" do
          expect(filename).to contain(/require 'rails_helper'/)
                             .and(contain(/^RSpec.describe "(.*)\/index", #{type_metatag(:view)}/))
                             .and(contain(/assign\(:posts, /))
                             .and(contain(/it "renders a list of (.*)"/))

          expect(filename).to contain(/'div>p'/)
        end
      end

      describe 'new' do
        subject(:filename) { file("spec/views/posts/new.html.erb_spec.rb") }

        it "includes the standard boilerplate" do
          expect(filename).to contain(/require 'rails_helper'/)
                             .and(contain(/^RSpec.describe "(.*)\/new", #{type_metatag(:view)}/))
                             .and(contain(/assign\(:post, /))
                             .and(contain(/it "renders new (.*) form"/))
        end
      end

      describe 'show' do
        subject(:filename) { file("spec/views/posts/show.html.erb_spec.rb") }

        it "includes the standard boilerplate" do
          expect(filename).to contain(/require 'rails_helper'/)
                             .and(contain(/^RSpec.describe "(.*)\/show", #{type_metatag(:view)}/))
                             .and(contain(/assign\(:post, /))
                             .and(contain(/it "renders attributes in <p>"/))
        end
      end
    end

    describe 'with multiple integer attributes index' do
      before { run_generator %w[posts upvotes:integer downvotes:integer] }
      subject(:filename) { file("spec/views/posts/index.html.erb_spec.rb") }

      it "includes the standard boilerplate" do
        expect(filename).to contain('assert_select cell_selector, text: Regexp.new(2.to_s), count: 2')
                           .and(contain('assert_select cell_selector, text: Regexp.new(3.to_s), count: 2'))
      end
    end

    describe 'with multiple float attributes index' do
      before { run_generator %w[posts upvotes:float downvotes:float] }
      subject(:filename) { file("spec/views/posts/index.html.erb_spec.rb") }

      it "includes the standard boilerplate" do
        expect(filename).to contain('assert_select cell_selector, text: Regexp.new(2.5.to_s), count: 2')
                           .and(contain('assert_select cell_selector, text: Regexp.new(3.5.to_s), count: 2'))
      end
    end

    describe 'with reference attribute' do
      before { run_generator %w[posts title:string author:references] }

      describe 'edit' do
        subject(:filename) { file("spec/views/posts/edit.html.erb_spec.rb") }

        it "includes the standard boilerplate" do
          expect(filename).to contain(/assert_select "input\[name=\?\]", "post\[author_id\]/)
                               .and(contain(/assert_select "input\[name=\?\]", "post\[title\]/))
        end
      end

      describe 'new' do
        subject(:filename) { file("spec/views/posts/new.html.erb_spec.rb") }

        it "includes the standard boilerplate" do
          expect(filename).to contain(/assert_select "input\[name=\?\]", "post\[author_id\]"/)
                                .and(contain(/assert_select "input\[name=\?\]", "post\[title\]/))
        end
      end
    end

    describe 'with namespace' do
      before { run_generator %w[admin/posts] }

      describe 'edit' do
        subject(:filename) { file("spec/views/admin/posts/edit.html.erb_spec.rb") }

        it "includes the standard boilerplate" do
          expect(filename).to contain(/assign\(:admin_post, admin_post\)/)
        end
      end

      describe 'index' do
        subject(:filename) { file("spec/views/admin/posts/index.html.erb_spec.rb") }

        it "includes the standard boilerplate" do
          expect(filename).to contain(/assign\(:admin_posts, /)
        end
      end

      describe 'new' do
        subject(:filename) { file("spec/views/admin/posts/new.html.erb_spec.rb") }

        it "includes the standard boilerplate" do
          expect(filename).to contain(/assign\(:admin_post, /)
        end
      end

      describe 'show' do
        subject(:filename) { file("spec/views/admin/posts/show.html.erb_spec.rb") }

        it "includes the standard boilerplate" do
          expect(filename).to contain(/assign\(:admin_post, /)
        end
      end
    end

    describe 'with namespace and --model-name' do
      before { run_generator %w[admin/posts --model-name=Post] }

      describe 'edit' do
        subject(:filename) { file("spec/views/admin/posts/edit.html.erb_spec.rb") }

        it "includes the standard boilerplate" do
          expect(filename).to contain(/assign\(:post, post\)/)
        end
      end

      describe 'index' do
        subject(:filename) { file("spec/views/admin/posts/index.html.erb_spec.rb") }

        it "includes the standard boilerplate" do
          expect(filename).to contain(/assign\(:posts, /)
        end
      end

      describe 'new' do
        subject(:filename) { file("spec/views/admin/posts/new.html.erb_spec.rb") }

        it "includes the standard boilerplate" do
          expect(filename).to contain(/assign\(:post, /)
        end
      end

      describe 'show' do
        subject(:filename) { file("spec/views/admin/posts/show.html.erb_spec.rb") }

        it "includes the standard boilerplate" do
          expect(filename).to contain(/assign\(:post, /)
        end
      end
    end

    describe 'with --no-template-engine' do
      before { run_generator %w[posts --no-template-engine] }
      describe 'edit' do
        subject(:filename) { file("spec/views/posts/edit.html._spec.rb") }

        it "skips the file" do
          expect(File.exist?(filename)).to be false
        end
      end

      describe 'index' do
        subject(:filename) { file("spec/views/posts/index.html._spec.rb") }

        it "skips the file" do
          expect(File.exist?(filename)).to be false
        end
      end

      describe 'new' do
        subject(:filename) { file("spec/views/posts/new.html._spec.rb") }

        it "skips the file" do
          expect(File.exist?(filename)).to be false
        end
      end

      describe 'show' do
        subject(:filename) { file("spec/views/posts/show.html._spec.rb") }

        it "skips the file" do
          expect(File.exist?(filename)).to be false
        end
      end
    end

    describe 'with --api' do
      before { run_generator %w[posts --api] }

      describe 'edit' do
        subject(:filename) { file("spec/views/posts/edit.html.erb_spec.rb") }

        it "skips the file" do
          expect(File.exist?(filename)).to be false
        end
      end

      describe 'index' do
        subject(:filename) { file("spec/views/posts/index.html.erb_spec.rb") }

        it "skips the file" do
          expect(File.exist?(filename)).to be false
        end
      end

      describe 'new' do
        subject(:filename) { file("spec/views/posts/index.html.erb_spec.rb") }

        it "skips the file" do
          expect(File.exist?(filename)).to be false
        end
      end

      describe 'show' do
        subject(:filename) { file("spec/views/posts/index.html.erb_spec.rb") }

        it "skips the file" do
          expect(File.exist?(filename)).to be false
        end
      end
    end

    describe 'with --no-view-specs' do
      before { run_generator %w[posts --no-view-specs] }

      describe 'edit' do
        subject(:filename) { file("spec/views/posts/edit.html.erb_spec.rb") }

        it "skips the file" do
          expect(File.exist?(filename)).to be false
        end
      end

      describe 'index' do
        subject(:filename) { file("spec/views/posts/index.html.erb_spec.rb") }

        it "skips the file" do
          expect(File.exist?(filename)).to be false
        end
      end

      describe 'new' do
        subject(:filename) { file("spec/views/posts/new.html.erb_spec.rb") }

        it "skips the file" do
          expect(File.exist?(filename)).to be false
        end
      end

      describe 'show' do
        subject(:filename) { file("spec/views/posts/show.html.erb_spec.rb") }

        it "skips the file" do
          expect(File.exist?(filename)).to be false
        end
      end
    end
  end

  describe 'routing spec' do
    subject(:filename) { file('spec/routing/posts_routing_spec.rb') }

    describe 'with default options' do
      before { run_generator %w[posts] }

      it 'includes the standard boilerplate' do
        expect(filename).to contain(/require "rails_helper"/)
                             .and(contain(/^RSpec.describe PostsController, #{type_metatag(:routing)}/))
                             .and(contain(/describe "routing"/))
                             .and(contain(/routes to #new/))
                             .and(contain(/routes to #edit/))
                             .and(contain('route_to("posts#new")'))
      end
    end

    describe 'with --no-routing-specs' do
      before { run_generator %w[posts --no-routing_specs] }

      it "skips the file" do
        expect(File.exist?(filename)).to be false
      end
    end

    describe 'with --api' do
      before { run_generator %w[posts --api] }

      it 'skips the right content' do
        expect(filename).not_to contain(/routes to #new/)
        expect(filename).not_to contain(/routes to #edit/)
      end
    end

    context 'with a namespaced name' do
      subject(:filename) { file('spec/routing/api/v1/posts_routing_spec.rb') }

      describe 'with default options' do
        before { run_generator %w[api/v1/posts] }

        it 'includes the standard boilerplate' do
          expect(filename).to contain(/^RSpec.describe Api::V1::PostsController, #{type_metatag(:routing)}/)
                               .and(contain('route_to("api/v1/posts#new")'))
        end
      end
    end
  end
end
