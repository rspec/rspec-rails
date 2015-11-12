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
      def perform(*)
      end
    end
  end

  let(:logging_job) do
    Class.new(ActiveJob::Base) do
      def perform; end
    end
  end

  let(:global_id_model) do
    Class.new do
      include GlobalID::Identification

      attr_reader :id

      def self.find(id)
        new(id)
      end

      def self.name
        "AnonymousClass"
      end

      def initialize(id)
        @id = id
      end

      def to_global_id(options = {})
        @global_id ||= GlobalID.create(self, :app => "rspec-suite")
      end
    end
  end

  before do
    ActiveJob::Base.queue_adapter = :test
  end

  describe "have_enqueued_job" do
    it "raises ArgumentError when no Proc passed to expect" do
      expect {
        expect(heavy_lifting_job.perform_later).to have_enqueued_job
      }.to raise_error(ArgumentError)
    end

    it "passess with default one number" do
      expect {
        heavy_lifting_job.perform_later
      }.to have_enqueued_job
    end

    it "counts only jobs enqueued in block" do
      heavy_lifting_job.perform_later
      expect {
        heavy_lifting_job.perform_later
      }.to have_enqueued_job.exactly(1)
    end

    it "passess when negated" do
      expect { }.not_to have_enqueued_job
    end

    it "fails when job is not enqueued" do
      expect {
        expect { }.to have_enqueued_job
      }.to raise_error(/expected to enqueue exactly 1 jobs, but enqueued 0/)
    end

    it "fails when too many jobs enqueued" do
      expect {
        expect {
          heavy_lifting_job.perform_later
          heavy_lifting_job.perform_later
        }.to have_enqueued_job.exactly(1)
      }.to raise_error(/expected to enqueue exactly 1 jobs, but enqueued 2/)
    end

    it "reports correct number in fail error message" do
      heavy_lifting_job.perform_later
      expect {
        expect { }.to have_enqueued_job.exactly(1)
      }.to raise_error(/expected to enqueue exactly 1 jobs, but enqueued 0/)
    end

    it "fails when negated and job is enqueued" do
      expect {
        expect { heavy_lifting_job.perform_later }.not_to have_enqueued_job
      }.to raise_error(/expected not to enqueue exactly 1 jobs, but enqueued 1/)
    end

    it "passes with job name" do
      expect {
        hello_job.perform_later
        heavy_lifting_job.perform_later
      }.to have_enqueued_job(hello_job).exactly(1).times
    end

    it "passes with multiple jobs" do
      expect {
        hello_job.perform_later
        logging_job.perform_later
        heavy_lifting_job.perform_later
      }.to have_enqueued_job(hello_job).and have_enqueued_job(logging_job)
    end

    it "passess with :once count" do
      expect {
        hello_job.perform_later
      }.to have_enqueued_job.exactly(:once)
    end

    it "passess with :twice count" do
      expect {
        hello_job.perform_later
        hello_job.perform_later
      }.to have_enqueued_job.exactly(:twice)
    end

    it "passess with :thrice count" do
      expect {
        hello_job.perform_later
        hello_job.perform_later
        hello_job.perform_later
      }.to have_enqueued_job.exactly(:thrice)
    end

    it "passess with at_least count when enqueued jobs are over limit" do
      expect {
        hello_job.perform_later
        hello_job.perform_later
      }.to have_enqueued_job.at_least(:once)
    end

    it "passess with at_most count when enqueued jobs are under limit" do
      expect {
        hello_job.perform_later
      }.to have_enqueued_job.at_most(:once)
    end

    it "generates failure message with at least hint" do
      expect {
        expect { }.to have_enqueued_job.at_least(:once)
      }.to raise_error(/expected to enqueue at least 1 jobs, but enqueued 0/)
    end

    it "generates failure message with at most hint" do
      expect {
        expect {
          hello_job.perform_later
          hello_job.perform_later
        }.to have_enqueued_job.at_most(:once)
      }.to raise_error(/expected to enqueue at most 1 jobs, but enqueued 2/)
    end

    it "passes with provided queue name" do
      expect {
        hello_job.set(:queue => "low").perform_later
      }.to have_enqueued_job.on_queue("low")
    end

    it "passes with provided at date" do
      date = Date.tomorrow.noon
      expect {
        hello_job.set(:wait_until => date).perform_later
      }.to have_enqueued_job.at(date)
    end

    it "passes with provided arguments" do
      expect {
        hello_job.perform_later(42, "David")
      }.to have_enqueued_job.with(42, "David")
    end

    it "passes with provided arguments containing global id object" do
      global_id_object = global_id_model.new(42)

      expect {
        hello_job.perform_later(global_id_object)
      }.to have_enqueued_job.with(global_id_object)
    end

    it "generates failure message with all provided options" do
      date = Date.tomorrow.noon
      message = "expected to enqueue exactly 2 jobs, with [42], on queue low, at #{date}, but enqueued 0"

      expect {
        expect {
          hello_job.perform_later
        }.to have_enqueued_job(hello_job).with(42).on_queue("low").at(date).exactly(2).times
      }.to raise_error(message)
    end

    it "throws descriptive error when no test adapter set" do
      queue_adapter = ActiveJob::Base.queue_adapter
      ActiveJob::Base.queue_adapter = :inline

      expect {
        expect { heavy_lifting_job.perform_later }.to have_enqueued_job
      }.to raise_error("To use have_enqueued_job matcher set `ActiveJob::Base.queue_adapter = :test`")

      ActiveJob::Base.queue_adapter = queue_adapter
    end
  end
end
