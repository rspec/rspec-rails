require 'spec_helper'

# Generators are not automatically loaded by Rails
require 'generators/rspec/mailer/mailer_generator'

describe Rspec::Generators::MailerGenerator do
  # Tell the generator where to put its output (what it thinks of as Rails.root)
  destination File.expand_path("../../../../../tmp", __FILE__)

  before { prepare_destination }

  describe 'mailer spec' do
    subject { file('spec/mailers/posts_spec.rb') }
    describe 'a spec is created for each action' do
      before do
        run_generator %w(posts index show)
      end
      it { is_expected.to exist }
      it { is_expected.to contain(/require "spec_helper"/) }
      it { is_expected.to contain(/describe "index" do/) }
      it { is_expected.to contain(/describe "show" do/) }
    end
    describe 'creates placeholder when no actions specified' do
      before do
        run_generator %w(posts)
      end
      it { is_expected.to exist }
      it { is_expected.to contain(/require "spec_helper"/) }
      it { is_expected.to contain(/pending "add some examples to \(or delete\)/) }
    end
  end

  describe 'a fixture is generated for each action' do
    before do
      run_generator %w(posts index show)
    end
    describe 'index' do
      subject { file('spec/fixtures/posts/index') }
      it { is_expected.to exist }
      it { is_expected.to contain(/Posts#index/) }
    end
    describe 'show' do
      subject { file('spec/fixtures/posts/show') }
      it { is_expected.to exist }
      it { is_expected.to contain(/Posts#show/) }
    end
  end
end
