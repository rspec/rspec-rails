require "rspec/rails/feature_check"

if RSpec::Rails::FeatureCheck.has_active_job?
  require "rspec/rails/matchers/active_job"

  class GlobalIdModel
    include GlobalID::Identification

    attr_reader :id

    def self.find(id)
      new(id)
    end

    def initialize(id)
      @id = id
    end

    def ==(comparison_object)
      (GlobalIdModel === comparison_object) && (id == comparison_object.id)
    end

    def to_global_id(_options = {})
      @global_id ||= GlobalID.create(self, app: "rspec-suite")
    end
  end

  class FailingGlobalIdModel < GlobalIdModel
    def self.find(_id)
      raise URI::GID::MissingModelIdError
    end
  end
end

RSpec.describe "ActiveJob matchers", skip: !RSpec::Rails::FeatureCheck.has_active_job? do
  include ActiveSupport::Testing::TimeHelpers

  around do |example|
    original_logger = ActiveJob::Base.logger
    ActiveJob::Base.logger = Logger.new(nil) # Silence messages "[ActiveJob] Enqueued ...".
    example.run
    ActiveJob::Base.logger = original_logger
  end

  around do |example|
    original_value = RSpec::Mocks.configuration.verify_partial_doubles?
    example.run
  ensure
    RSpec::Mocks.configuration.verify_partial_doubles = original_value
  end

  let(:heavy_lifting_job) do
    Class.new(ActiveJob::Base) do
      def perform; end
      def self.name; "HeavyLiftingJob"; end
    end
  end

  let(:hello_job) do
    Class.new(ActiveJob::Base) do
      def perform(*)
      end
      def self.name; "HelloJob"; end
    end
  end

  let(:logging_job) do
    Class.new(ActiveJob::Base) do
      def perform; end
      def self.name; "LoggingJob"; end
    end
  end

  let(:two_args_job) do
    Class.new(ActiveJob::Base) do
      def perform(one, two); end
      def self.name; "TwoArgsJob"; end
    end
  end

  let(:keyword_args_job) do
    Class.new(ActiveJob::Base) do
      def perform(one:, two:); end
      def self.name; "KeywordArgsJob"; end
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

    it "passes with default jobs count (exactly one)" do
      expect {
        heavy_lifting_job.perform_later
      }.to have_enqueued_job
    end

    it "passes when using alias" do
      expect {
        heavy_lifting_job.perform_later
      }.to enqueue_job
    end

    it "counts only jobs enqueued in block" do
      heavy_lifting_job.perform_later
      expect {
        heavy_lifting_job.perform_later
      }.to have_enqueued_job.exactly(1)
    end

    it "passes when negated" do
      expect { }.not_to have_enqueued_job
    end

    context "when previously enqueued jobs were performed" do
      include ActiveJob::TestHelper

      before { stub_const("HeavyLiftingJob", heavy_lifting_job) }

      it "counts newly enqueued jobs" do
        heavy_lifting_job.perform_later
        expect {
          perform_enqueued_jobs
          hello_job.perform_later
        }.to have_enqueued_job(hello_job)
      end
    end

    context "when job is retried" do
      include ActiveJob::TestHelper

      let(:unreliable_job) do
        Class.new(ActiveJob::Base) do
          retry_on StandardError, wait: 5, queue: :retry

          def self.name; "UnreliableJob"; end
          def perform; raise StandardError; end
        end
      end

      before { stub_const("UnreliableJob", unreliable_job) }

      it "passes with reenqueued job" do
        time = Time.current.change(usec: 0)
        travel_to time do
          UnreliableJob.perform_later
          expect { perform_enqueued_jobs }.to have_enqueued_job(UnreliableJob).on_queue(:retry).at(time + 5)
        end
      end
    end

    it "fails when job is not enqueued" do
      expect {
        expect { }.to have_enqueued_job
      }.to fail_with(/expected to enqueue exactly 1 jobs, but enqueued 0/)
    end

    it "fails when too many jobs enqueued" do
      expect {
        expect {
          heavy_lifting_job.perform_later
          heavy_lifting_job.perform_later
        }.to have_enqueued_job.exactly(1)
      }.to fail_with(/expected to enqueue exactly 1 jobs, but enqueued 2/)
    end

    it "reports correct number in fail error message" do
      heavy_lifting_job.perform_later
      expect {
        expect { }.to have_enqueued_job.exactly(1)
      }.to fail_with(/expected to enqueue exactly 1 jobs, but enqueued 0/)
    end

    it "fails when negated and job is enqueued" do
      expect {
        expect { heavy_lifting_job.perform_later }.not_to have_enqueued_job
      }.to fail_with(/expected not to enqueue at least 1 jobs, but enqueued 1/)
    end

    it "fails when negated and several jobs enqueued" do
      expect {
        expect {
          heavy_lifting_job.perform_later
          heavy_lifting_job.perform_later
        }.not_to have_enqueued_job
      }.to fail_with(/expected not to enqueue at least 1 jobs, but enqueued 2/)
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

    it "passes with :once count" do
      expect {
        hello_job.perform_later
      }.to have_enqueued_job.exactly(:once)
    end

    it "passes with :twice count" do
      expect {
        hello_job.perform_later
        hello_job.perform_later
      }.to have_enqueued_job.exactly(:twice)
    end

    it "passes with :thrice count" do
      expect {
        hello_job.perform_later
        hello_job.perform_later
        hello_job.perform_later
      }.to have_enqueued_job.exactly(:thrice)
    end

    it "passes with at_least count when enqueued jobs are over limit" do
      expect {
        hello_job.perform_later
        hello_job.perform_later
      }.to have_enqueued_job.at_least(:once)
    end

    it "passes with at_most count when enqueued jobs are under limit" do
      expect {
        hello_job.perform_later
      }.to have_enqueued_job.at_most(:once)
    end

    it "generates failure message with at least hint" do
      expect {
        expect { }.to have_enqueued_job.at_least(:once)
      }.to fail_with(/expected to enqueue at least 1 jobs, but enqueued 0/)
    end

    it "generates failure message with at most hint" do
      expect {
        expect {
          hello_job.perform_later
          hello_job.perform_later
        }.to have_enqueued_job.at_most(:once)
      }.to fail_with(/expected to enqueue at most 1 jobs, but enqueued 2/)
    end

    it "passes with provided queue name as string" do
      expect {
        hello_job.set(queue: "low").perform_later
      }.to have_enqueued_job.on_queue("low")
    end

    it "passes with provided queue name as symbol" do
      expect {
        hello_job.set(queue: "low").perform_later
      }.to have_enqueued_job.on_queue(:low)
    end

    it "passes with provided priority number as integer" do
      expect {
        hello_job.set(priority: 2).perform_later
      }.to have_enqueued_job.at_priority(2)
    end

    it "passes with provided priority number as string" do
      expect {
        hello_job.set(priority: 2).perform_later
      }.to have_enqueued_job.at_priority("2")
    end

    it "fails when the priority wan't set" do
      expect {
        expect {
          hello_job.perform_later
        }.to have_enqueued_job.at_priority(2)
      }.to fail_with(/expected to enqueue exactly 1 jobs, with priority 2, but enqueued 0.+ with no priority specified/m)
    end

    it "fails when the priority was set to a different value" do
      expect {
        expect {
          hello_job.set(priority: 1).perform_later
        }.to have_enqueued_job.at_priority(2)
      }.to fail_with(/expected to enqueue exactly 1 jobs, with priority 2, but enqueued 0.+ with priority 1/m)
    end

    pending "accepts matchers as arguments to at_priority" do
      expect {
        hello_job.set(priority: 1).perform_later
      }.to have_enqueued_job.at_priority(eq(1))
    end

    it "passes with provided at date" do
      date = Date.tomorrow.noon
      expect {
        hello_job.set(wait_until: date).perform_later
      }.to have_enqueued_job.at(date)
    end

    it "passes with provided at time" do
      time = Time.now + 1.day
      expect {
        hello_job.set(wait_until: time).perform_later
      }.to have_enqueued_job.at(time)
    end

    it "works with time offsets" do
      # NOTE: Time.current does not replicate Rails behavior for 5 seconds from now.
      time = Time.current.change(usec: 0)
      travel_to time do
        expect { hello_job.set(wait: 5).perform_later }.to have_enqueued_job.at(time + 5)
      end
    end

    it "warns when time offsets are inprecise" do
      expect(RSpec).to receive(:warn_with).with(/precision error/)

      time = Time.current.change(usec: 550)
      travel_to time do
        expect {
          expect { hello_job.set(wait: 5).perform_later }.to have_enqueued_job.at(time + 5)
        }.to fail_with(/expected to enqueue exactly 1 jobs/)
      end
    end

    it "accepts composable matchers as an at date" do
      future = 1.minute.from_now
      slightly_earlier = 58.seconds.from_now
      expect {
        hello_job.set(wait_until: slightly_earlier).perform_later
      }.to have_enqueued_job.at(a_value_within(5.seconds).of(future))
    end

    it "has an enqueued job when providing at of :no_wait and there is no wait" do
      expect {
        hello_job.perform_later
      }.to have_enqueued_job.at(:no_wait)
    end

    it "has an enqueued job when providing at and there is no wait" do
      date = Date.tomorrow.noon
      expect {
        expect {
          hello_job.perform_later
        }.to have_enqueued_job.at(date)
      }.to fail_with(/expected to enqueue exactly 1 jobs, at .+ but enqueued 0/)
    end

    it "has an enqueued job when not providing at and there is a wait" do
      date = Date.tomorrow.noon
      expect {
        hello_job.set(wait_until: date).perform_later
      }.to have_enqueued_job
    end

    it "does not have an enqueued job when providing at of :no_wait and there is a wait" do
      date = Date.tomorrow.noon
      expect {
        hello_job.set(wait_until: date).perform_later
      }.to_not have_enqueued_job.at(:no_wait)
    end

    it "passes with provided arguments" do
      expect {
        hello_job.perform_later(42, "David")
      }.to have_enqueued_job.with(42, "David")
    end

    describe "verifying the arguments passed match the job's signature" do
      it "fails if there is an arity mismatch" do
        expect {
          expect {
            two_args_job.perform_later(1)
          }.to have_enqueued_job.with(1)
        }.to fail_with(/Incorrect arguments passed to TwoArgsJob: Wrong number of arguments/)
      end

      it "fails if there is a keyword/positional arguments mismatch" do
        expect {
          expect {
            keyword_args_job.perform_later(1, 2)
          }.to have_enqueued_job.with(1, 2)
        }.to fail_with(/Incorrect arguments passed to KeywordArgsJob: Missing required keyword arguments/)
      end

      context "with partial double verification disabled" do
        before do
          RSpec::Mocks.configuration.verify_partial_doubles = false
        end

        it "skips signature checks" do
          expect { two_args_job.perform_later(1) }.to have_enqueued_job.with(1)
        end
      end

      context "when partial double verification is temporarily suspended" do
        it "skips signature checks" do
          without_partial_double_verification {
            expect {
              two_args_job.perform_later(1)
            }.to have_enqueued_job.with(1)
          }
        end
      end

      context "without rspec-mocks loaded" do
        before do
          # Its hard for us to unload this, but its fairly safe to assume that we can run
          # a defined? check, this just mocks the "short circuit"
          allow(::RSpec::Mocks).to receive(:respond_to?).with(:configuration) { false }
        end

        it "skips signature checks" do
          expect { two_args_job.perform_later(1) }.to have_enqueued_job.with(1)
        end
      end
    end

    it "passes with provided arguments containing global id object" do
      global_id_object = GlobalIdModel.new("42")

      expect {
        hello_job.perform_later(global_id_object)
      }.to have_enqueued_job.with(global_id_object)
    end

    it "passes with provided argument matchers" do
      expect {
        hello_job.perform_later(42, "David")
      }.to have_enqueued_job.with(42, "David")
    end

    it "generates failure message with all provided options" do
      date = Date.tomorrow.noon
      message = "expected to enqueue exactly 2 jobs, with [42], on queue low, at #{date}, with priority 5, but enqueued 0" \
                "\nQueued jobs:" \
                "\n  HelloJob job with [1], on queue default, with no priority specified"

      expect {
        expect {
          hello_job.perform_later(1)
        }.to have_enqueued_job(hello_job).with(42).on_queue("low").at(date).at_priority(5).exactly(2).times
      }.to fail_with(message)
    end

    it "throws descriptive error when no test adapter set" do
      queue_adapter = ActiveJob::Base.queue_adapter
      ActiveJob::Base.queue_adapter = :inline

      expect {
        expect { heavy_lifting_job.perform_later }.to have_enqueued_job
      }.to raise_error("To use ActiveJob matchers set `ActiveJob::Base.queue_adapter = :test`")

      ActiveJob::Base.queue_adapter = queue_adapter
    end

    it "fails with with block with incorrect data" do
      expect {
        expect {
          hello_job.perform_later("asdf")
        }.to have_enqueued_job(hello_job).with { |arg|
          expect(arg).to eq("zxcv")
        }
      }.to raise_error { |e|
        expect(e.message).to match(/expected: "zxcv"/)
        expect(e.message).to match(/got: "asdf"/)
      }
    end

    it "passes multiple arguments to with block" do
      expect {
        hello_job.perform_later("asdf", "zxcv")
      }.to have_enqueued_job(hello_job).with { |first_arg, second_arg|
        expect(first_arg).to eq("asdf")
        expect(second_arg).to eq("zxcv")
      }
    end

    it "passes deserialized arguments to with block" do
      global_id_object = GlobalIdModel.new("42")

      expect {
        hello_job.perform_later(global_id_object, symbolized_key: "asdf")
      }.to have_enqueued_job(hello_job).with { |first_arg, second_arg|
        expect(first_arg).to eq(global_id_object)
        expect(second_arg).to eq({ symbolized_key: "asdf" })
      }
    end

    it "ignores undeserializable arguments" do
      failing_global_id_object = FailingGlobalIdModel.new("21")
      global_id_object = GlobalIdModel.new("42")

      expect {
        hello_job.perform_later(failing_global_id_object)
        hello_job.perform_later(global_id_object)
      }.to have_enqueued_job(hello_job).with(global_id_object)
    end

    it "only calls with block if other conditions are met" do
      noon = Date.tomorrow.noon
      midnight = Date.tomorrow.midnight
      expect {
        hello_job.set(wait_until: noon).perform_later("asdf")
        hello_job.set(wait_until: midnight).perform_later("zxcv")
      }.to have_enqueued_job(hello_job).at(noon).with { |arg|
        expect(arg).to eq("asdf")
      }
    end

    it "passes with Time" do
      usec_time = Time.iso8601('2016-07-01T00:00:00.000001Z')

      expect {
        hello_job.perform_later(usec_time)
      }.to have_enqueued_job(hello_job).with(usec_time)
    end

    it "passes with ActiveSupport::TimeWithZone" do
      usec_time = Time.iso8601('2016-07-01T00:00:00.000001Z').in_time_zone

      expect {
        hello_job.perform_later(usec_time)
      }.to have_enqueued_job(hello_job).with(usec_time)
    end
  end

  describe "have_been_enqueued" do
    before { ActiveJob::Base.queue_adapter.enqueued_jobs.clear }

    it "raises RSpec::Expectations::ExpectationNotMetError when Proc passed to expect" do
      expect {
        expect { heavy_lifting_job }.to have_been_enqueued
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end

    it "passes with default jobs count (exactly one)" do
      heavy_lifting_job.perform_later
      expect(heavy_lifting_job).to have_been_enqueued
    end

    it "counts all enqueued jobs" do
      heavy_lifting_job.perform_later
      heavy_lifting_job.perform_later
      expect(heavy_lifting_job).to have_been_enqueued.exactly(2)
    end

    it "passes when negated" do
      expect(heavy_lifting_job).not_to have_been_enqueued
    end

    it "fails when job is not enqueued" do
      expect {
        expect(heavy_lifting_job).to have_been_enqueued
      }.to fail_with(/expected to enqueue exactly 1 jobs, but enqueued 0/)
    end

    describe "verifying the arguments passed match the job's signature" do
      it "fails if there is an arity mismatch" do
        two_args_job.perform_later(1)

        expect {
          expect(two_args_job).to have_been_enqueued.with(1)
        }.to fail_with(/Incorrect arguments passed to TwoArgsJob: Wrong number of arguments/)
      end

      it "fails if there is a keyword/positional arguments mismatch" do
        keyword_args_job.perform_later(1, 2)

        expect {
          expect(keyword_args_job).to have_been_enqueued.with(1, 2)
        }.to fail_with(/Incorrect arguments passed to KeywordArgsJob: Missing required keyword arguments/)
      end

      context "with partial double verification disabled" do
        before do
          RSpec::Mocks.configuration.verify_partial_doubles = false
        end

        it "skips signature checks" do
          keyword_args_job.perform_later(1, 2)

          expect(keyword_args_job).to have_been_enqueued.with(1, 2)
        end
      end

      context "when partial double verification is temporarily suspended" do
        it "skips signature checks" do
          keyword_args_job.perform_later(1, 2)

          without_partial_double_verification {
            expect(keyword_args_job).to have_been_enqueued.with(1, 2)
          }
        end
      end
    end

    it "fails when negated and several jobs enqueued" do
      heavy_lifting_job.perform_later
      heavy_lifting_job.perform_later
      expect {
        expect(heavy_lifting_job).not_to have_been_enqueued
      }.to fail_with(/expected not to enqueue at least 1 jobs, but enqueued 2/)
    end

    it "accepts composable matchers as an at date" do
      future = 1.minute.from_now
      slightly_earlier = 58.seconds.from_now
      heavy_lifting_job.set(wait_until: slightly_earlier).perform_later
      expect(heavy_lifting_job)
        .to have_been_enqueued.at(a_value_within(5.seconds).of(future))
    end
  end

  describe "have_performed_job" do
    before do
      ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
      ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = true

      # stub_const is used so `job_data["job_class"].constantize` works
      stub_const('HeavyLiftingJob', heavy_lifting_job)
      stub_const('HelloJob', hello_job)
      stub_const('LoggingJob', logging_job)
    end

    it "raises ArgumentError when no Proc passed to expect" do
      expect {
        expect(heavy_lifting_job.perform_later).to have_performed_job
      }.to raise_error(ArgumentError)
    end

    it "passes with default jobs count (exactly one)" do
      expect {
        heavy_lifting_job.perform_later
      }.to have_performed_job
    end

    it "counts only jobs performed in block" do
      heavy_lifting_job.perform_later
      expect {
        heavy_lifting_job.perform_later
      }.to have_performed_job.exactly(1)
    end

    it "passes when negated" do
      expect { }.not_to have_performed_job
    end

    it "fails when job is not performed" do
      expect {
        expect { }.to have_performed_job
      }.to fail_with(/expected to perform exactly 1 jobs, but performed 0/)
    end

    it "fails when too many jobs performed" do
      expect {
        expect {
          heavy_lifting_job.perform_later
          heavy_lifting_job.perform_later
        }.to have_performed_job.exactly(1)
      }.to fail_with(/expected to perform exactly 1 jobs, but performed 2/)
    end

    it "reports correct number in fail error message" do
      heavy_lifting_job.perform_later
      expect {
        expect { }.to have_performed_job.exactly(1)
      }.to fail_with(/expected to perform exactly 1 jobs, but performed 0/)
    end

    it "fails when negated and job is performed" do
      expect {
        expect { heavy_lifting_job.perform_later }.not_to have_performed_job
      }.to fail_with(/expected not to perform exactly 1 jobs, but performed 1/)
    end

    it "passes with job name" do
      expect {
        hello_job.perform_later
        heavy_lifting_job.perform_later
      }.to have_performed_job(hello_job).exactly(1).times
    end

    it "passes with multiple jobs" do
      expect {
        hello_job.perform_later
        logging_job.perform_later
        heavy_lifting_job.perform_later
      }.to have_performed_job(hello_job).and have_performed_job(logging_job)
    end

    it "passes with :once count" do
      expect {
        hello_job.perform_later
      }.to have_performed_job.exactly(:once)
    end

    it "passes with :twice count" do
      expect {
        hello_job.perform_later
        hello_job.perform_later
      }.to have_performed_job.exactly(:twice)
    end

    it "passes with :thrice count" do
      expect {
        hello_job.perform_later
        hello_job.perform_later
        hello_job.perform_later
      }.to have_performed_job.exactly(:thrice)
    end

    it "passes with at_least count when performed jobs are over limit" do
      expect {
        hello_job.perform_later
        hello_job.perform_later
      }.to have_performed_job.at_least(:once)
    end

    it "passes with at_most count when performed jobs are under limit" do
      expect {
        hello_job.perform_later
      }.to have_performed_job.at_most(:once)
    end

    it "generates failure message with at least hint" do
      expect {
        expect { }.to have_performed_job.at_least(:once)
      }.to fail_with(/expected to perform at least 1 jobs, but performed 0/)
    end

    it "generates failure message with at most hint" do
      expect {
        expect {
          hello_job.perform_later
          hello_job.perform_later
        }.to have_performed_job.at_most(:once)
      }.to fail_with(/expected to perform at most 1 jobs, but performed 2/)
    end

    it "passes with provided queue name as string" do
      expect {
        hello_job.set(queue: "low").perform_later
      }.to have_performed_job.on_queue("low")
    end

    it "passes with provided queue name as symbol" do
      expect {
        hello_job.set(queue: "low").perform_later
      }.to have_performed_job.on_queue(:low)
    end

    it "passes with provided at date" do
      date = Date.tomorrow.noon
      expect {
        hello_job.set(wait_until: date).perform_later
      }.to have_performed_job.at(date)
    end

    it "passes with provided arguments" do
      expect {
        hello_job.perform_later(42, "David")
      }.to have_performed_job.with(42, "David")
    end

    it "passes with provided arguments containing global id object" do
      global_id_object = GlobalIdModel.new("42")

      expect {
        hello_job.perform_later(global_id_object)
      }.to have_performed_job.with(global_id_object)
    end

    it "passes with provided argument matchers" do
      expect {
        hello_job.perform_later(42, "David")
      }.to have_performed_job.with(42, "David")
    end

    it "generates failure message with all provided options" do
      date = Date.tomorrow.noon
      message = "expected to perform exactly 2 jobs, with [42], on queue low, at #{date}, with priority 5, but performed 0" \
                "\nQueued jobs:" \
                "\n  HelloJob job with [1], on queue default, with no priority specified"

      expect {
        expect {
          hello_job.perform_later(1)
        }.to have_performed_job(hello_job).with(42).on_queue("low").at(date).at_priority(5).exactly(2).times
      }.to fail_with(message)
    end

    it "throws descriptive error when no test adapter set" do
      queue_adapter = ActiveJob::Base.queue_adapter
      ActiveJob::Base.queue_adapter = :inline

      expect {
        expect { heavy_lifting_job.perform_later }.to have_performed_job
      }.to raise_error("To use ActiveJob matchers set `ActiveJob::Base.queue_adapter = :test`")

      ActiveJob::Base.queue_adapter = queue_adapter
    end

    it "fails with with block with incorrect data" do
      expect {
        expect {
          hello_job.perform_later("asdf")
        }.to have_performed_job(hello_job).with { |arg|
          expect(arg).to eq("zxcv")
        }
      }.to raise_error { |e|
        expect(e.message).to match(/expected: "zxcv"/)
        expect(e.message).to match(/got: "asdf"/)
      }
    end

    it "passes multiple arguments to with block" do
      expect {
        hello_job.perform_later("asdf", "zxcv")
      }.to have_performed_job(hello_job).with { |first_arg, second_arg|
        expect(first_arg).to eq("asdf")
        expect(second_arg).to eq("zxcv")
      }
    end

    it "passes deserialized arguments to with block" do
      global_id_object = GlobalIdModel.new("42")

      expect {
        hello_job.perform_later(global_id_object, symbolized_key: "asdf")
      }.to have_performed_job(hello_job).with { |first_arg, second_arg|
        expect(first_arg).to eq(global_id_object)
        expect(second_arg).to eq({ symbolized_key: "asdf" })
      }
    end

    it "only calls with block if other conditions are met" do
      noon = Date.tomorrow.noon
      midnight = Date.tomorrow.midnight
      expect {
        hello_job.set(wait_until: noon).perform_later("asdf")
        hello_job.set(wait_until: midnight).perform_later("zxcv")
      }.to have_performed_job(hello_job).at(noon).with { |arg|
        expect(arg).to eq("asdf")
      }
    end
  end

  describe "have_been_performed" do
    before do
      ActiveJob::Base.queue_adapter.performed_jobs.clear
      ActiveJob::Base.queue_adapter.perform_enqueued_jobs = true
      ActiveJob::Base.queue_adapter.perform_enqueued_at_jobs = true
      stub_const('HeavyLiftingJob', heavy_lifting_job)
    end

    it "raises RSpec::Expectations::ExpectationNotMetError when Proc passed to expect" do
      expect {
        expect { heavy_lifting_job }.to have_been_performed
      }.to raise_error(RSpec::Expectations::ExpectationNotMetError)
    end

    it "passes with default jobs count (exactly one)" do
      heavy_lifting_job.perform_later
      expect(heavy_lifting_job).to have_been_performed
    end

    it "counts all performed jobs" do
      heavy_lifting_job.perform_later
      heavy_lifting_job.perform_later
      expect(heavy_lifting_job).to have_been_performed.exactly(2)
    end

    it "passes when negated" do
      expect(heavy_lifting_job).not_to have_been_performed
    end

    it "fails when job is not performed" do
      expect {
        expect(heavy_lifting_job).to have_been_performed
      }.to fail_with(/expected to perform exactly 1 jobs, but performed 0/)
    end
  end

  describe 'Active Job test helpers' do
    include ActiveJob::TestHelper

    it 'does not raise that "assert_nothing_raised" is undefined' do
      expect {
        perform_enqueued_jobs do
          :foo
        end
      }.to_not raise_error
    end
  end
end
