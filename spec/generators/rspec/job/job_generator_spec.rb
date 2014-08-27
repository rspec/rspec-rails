require 'spec_helper'

# Generators are not automatically loaded by Rails
require 'generators/rspec/job/job_generator'

RSpec.describe Rspec::Generators::JobGenerator, :type => :generator, :skip => !RSpec::Rails::FeatureCheck.has_active_job? do
  # Tell the generator where to put its output (what it thinks of as Rails.root)
  destination File.expand_path('../../../../../tmp', __FILE__)

  before { prepare_destination }

  describe 'the generated files' do
    before { run_generator %w(user) }

    subject { file('spec/jobs/user_job_spec.rb') }

    it { is_expected.to exist }
    it { is_expected.to contain(/require 'rails_helper'/) }
    it { is_expected.to contain(/describe UserJob, :type => :job/) }

  end
end
