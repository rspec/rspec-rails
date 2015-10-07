require "spec_helper"
require "rspec/rails/feature_check"
if RSpec::Rails::FeatureCheck.has_active_job?
  require "rspec/rails/matchers/active_job"
end

RSpec.describe "ActiveJob matchers", :skip => !RSpec::Rails::FeatureCheck.has_active_job? do
  include RSpec::Rails::Matchers

  let(:heavy_lifting_job) do
    Class.new(ActiveJob::Base) do
      def perform; end
    end
  end

  let(:hello_job) do
    Class.new(ActiveJob::Base) do
      def perform; end
    end
  end

  let(:logging_job) do
    Class.new(ActiveJob::Base) do
      def perform; end
    end
  end

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe "have_enqueued_jobs" do
    it "raises ArgumentError when no Proc passed to expect" do
      expect {
        expect(heavy_lifting_job.perform_later).to have_enqueued_jobs
      }.to raise_error(ArgumentError)
    end

    it "passess with default one number" do
      expect {
        heavy_lifting_job.perform_later
      }.to have_enqueued_jobs
    end

    it "counts only jobs enqueued in block" do
      heavy_lifting_job.perform_later
      expect {
        heavy_lifting_job.perform_later
      }.to have_enqueued_jobs.exactly(1)
    end

    it "passess when negated" do
      expect { }.not_to have_enqueued_jobs
    end

    it "fails when job is not enqueued" do
      expect {
        expect { }.to have_enqueued_jobs
      }.to raise_error(/expected to enqueue exactly 1 jobs, but enqueued 0/)
    end

    it "fails when too many jobs enqueued" do
      expect {
        expect {
          heavy_lifting_job.perform_later
          heavy_lifting_job.perform_later
        }.to have_enqueued_jobs.exactly(1)
      }.to raise_error(/expected to enqueue exactly 1 jobs, but enqueued 2/)
    end

    it "reports correct number in fail error message" do
      heavy_lifting_job.perform_later
      expect {
        expect { }.to have_enqueued_jobs.exactly(1)
      }.to raise_error(/expected to enqueue exactly 1 jobs, but enqueued 0/)
    end

    it "fails when negated and job is enqueued" do
      expect {
        expect { heavy_lifting_job.perform_later }.not_to have_enqueued_jobs
      }.to raise_error(/expected not to enqueue exactly 1 jobs, but enqueued 1/)
    end

    it "passes with job name" do
      expect {
        hello_job.perform_later
        heavy_lifting_job.perform_later
      }.to have_enqueued_jobs(hello_job).exactly(1).times
    end

    it "passes with multiple job names" do
      expect {
        hello_job.perform_later
        logging_job.perform_later
        heavy_lifting_job.perform_later
      }.to have_enqueued_jobs(hello_job, logging_job).exactly(2).times
    end

    it "passess with :once count" do
      expect {
        hello_job.perform_later
      }.to have_enqueued_jobs.exactly(:once)
    end

    it "passess with :twice count" do
      expect {
        hello_job.perform_later
        hello_job.perform_later
      }.to have_enqueued_jobs.exactly(:twice)
    end

    it "passess with :thrice count" do
      expect {
        hello_job.perform_later
        hello_job.perform_later
        hello_job.perform_later
      }.to have_enqueued_jobs.exactly(:thrice)
    end

    it "passess with at_least count when enqueued jobs are over limit" do
      expect {
        hello_job.perform_later
        hello_job.perform_later
      }.to have_enqueued_jobs.at_least(:once)
    end

    it "passess with at_most count when enqueued jobs are under limit" do
      expect {
        hello_job.perform_later
      }.to have_enqueued_jobs.at_most(:once)
    end

    it "generates failure message with at least hint" do
      expect {
        expect { }.to have_enqueued_jobs.at_least(:once)
      }.to raise_error(/expected to enqueue at least 1 jobs, but enqueued 0/)
    end

    it "generates failure message with at most hint" do
      expect {
        expect {
          hello_job.perform_later
          hello_job.perform_later
        }.to have_enqueued_jobs.at_most(:once)
      }.to raise_error(/expected to enqueue at most 1 jobs, but enqueued 2/)
    end
  end
end
