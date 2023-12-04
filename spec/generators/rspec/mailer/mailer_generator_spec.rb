# Generators are not automatically loaded by Rails
require 'generators/rspec/mailer/mailer_generator'
require 'support/generators'

RSpec.describe Rspec::Generators::MailerGenerator, type: :generator do
  setup_default_destination

  describe 'mailer spec' do
    subject(:filename) { file('spec/mailers/posts_spec.rb') }

    describe 'a spec is created for each action' do
      before do
        run_generator %w[posts index show]
      end

      it "includes the standard boilerplate" do
        # Rails 5+ automatically appends Mailer to the provided constant so we do too
        expect(
          filename
        ).to(
          contain(/require "rails_helper"/)
            .and(contain(/^RSpec.describe PostsMailer, #{type_metatag(:mailer)}/))
            .and(contain(/describe "index" do/))
            .and(contain(/describe "show" do/))
        )
      end
    end

    describe 'creates placeholder when no actions specified' do
      before do
        run_generator %w[posts]
      end

      it "includes the standard boilerplate" do
        expect(
          filename
        ).to contain(/require "rails_helper"/).and(contain(/pending "add some examples to \(or delete\)/))
      end
    end
  end

  describe 'a fixture is generated for each action' do
    before do
      run_generator %w[posts index show]
    end

    describe 'index' do
      subject(:filename) { file('spec/fixtures/posts/index') }

      it "includes the standard boilerplate" do
        expect(filename).to contain(/Posts#index/)
      end
    end

    describe 'show' do
      subject(:filename) { file('spec/fixtures/posts/show') }

      it "includes the standard boilerplate" do
        expect(filename).to contain(/Posts#show/)
      end
    end
  end

  describe 'a preview is generated for each action', skip: !RSpec::Rails::FeatureCheck.has_action_mailer_preview? do
    before do
      run_generator %w[posts index show]
    end

    subject(:filename) { file('spec/mailers/previews/posts_preview.rb') }

    it "includes the standard boilerplate" do
      expect(
        filename
      ).to(
        contain(/class PostsPreview < ActionMailer::Preview/)
          .and(contain(/def index/))
          .and(contain(/PostsMailer.index/))
          .and(contain(/def show/))
          .and(contain(/PostsMailer.show/))
      )
    end
  end
end
