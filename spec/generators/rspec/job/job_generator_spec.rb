# Generators are not automatically loaded by Rails
require 'generators/rspec/job/job_generator'
require 'support/generators'

RSpec.describe Rspec::Generators::JobGenerator, type: :generator, skip: !RSpec::Rails::FeatureCheck.has_active_job? do
  setup_default_destination

  describe 'the generated files' do
    before { run_generator [file_name] }

    subject(:job_spec) { file('spec/jobs/user_job_spec.rb') }

    context 'with file_name without job as suffix' do
      let(:file_name) { 'user' }

      it 'creates the standard boiler plate' do
        expect(job_spec).to contain(/require 'rails_helper'/).and(contain(/describe UserJob, #{type_metatag(:job)}/))
      end
    end

    context 'with file_name with job as suffix' do
      let(:file_name) { 'user_job' }

      it 'creates the standard boiler plate' do
        expect(job_spec).to contain(/require 'rails_helper'/).and(contain(/describe UserJob, #{type_metatag(:job)}/))
      end
    end
  end
end
