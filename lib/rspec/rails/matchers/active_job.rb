require "active_job/base"

module RSpec
  module Rails
    module Matchers
      # Namespace for various implementations of ActiveJob features
      #
      # @api private
      module ActiveJob
        # @private
        class HaveEnqueuedJob < RSpec::Matchers::BuiltIn::BaseMatcher
          def initialize(job)
            @job = job
            set_expected_number(:exactly, 1)
          end

          def matches?(proc)
            raise ArgumentError, "have_enqueued_jobs only supports block expectations" unless Proc === proc

            before_block_jobs_size = enqueued_jobs_size(@job)
            proc.call
            @in_block_jobs_size = enqueued_jobs_size(@job) - before_block_jobs_size

            case @expectation_type
            when :exactly then @expected_number == @in_block_jobs_size
            when :at_most then @expected_number >= @in_block_jobs_size
            when :at_least then @expected_number <= @in_block_jobs_size
            end
          end

          def exactly(count)
            set_expected_number(:exactly, count)
            self
          end

          def at_least(count)
            set_expected_number(:at_least, count)
            self
          end

          def at_most(count)
            set_expected_number(:at_most, count)
            self
          end

          def times
            self
          end

          def failure_message
            "expected to enqueue #{message_expectation_modifier} #{@expected_number} jobs, but enqueued #{@in_block_jobs_size}"
          end

          def failure_message_when_negated
            "expected not to enqueue #{message_expectation_modifier} #{@expected_number} jobs, but enqueued #{@in_block_jobs_size}"
          end

          def message_expectation_modifier
            case @expectation_type
            when :exactly then "exactly"
            when :at_most then "at most"
            when :at_least then "at least"
            end
          end

          def supports_block_expectations?
            true
          end

        private

          def enqueued_jobs_size(job)
            if job
              queue_adapter.enqueued_jobs.count { |enqueued_job| job == enqueued_job.fetch(:job) }
            else
              queue_adapter.enqueued_jobs.count
            end
          end

          def set_expected_number(relativity, count)
            @expectation_type = relativity
            @expected_number = case count
                               when :once then 1
                               when :twice then 2
                               when :thrice then 3
                               else Integer(count)
                               end
          end

          def queue_adapter
            ::ActiveJob::Base.queue_adapter
          end
        end
      end

      # @api public
      # Passess if `count` of jobs were enqueued inside block
      #
      # @example
      #     expect {
      #       HeavyLiftingJob.perform_later
      #     }.to have_enqueued_job
      #
      #     expect {
      #       HelloJob.perform_later
      #       HeavyLiftingJob.perform_later
      #     }.to have_enqueued_job(HelloJob).exactly(:once)
      #
      #     expect {
      #       HelloJob.perform_later
      #       HelloJob.perform_later
      #       HelloJob.perform_later
      #     }.to have_enqueued_job(HelloJob).at_least(2).times
      #
      #     expect {
      #       HelloJob.perform_later
      #     }.to have_enqueued_job(HelloJob).at_most(:twice)
      #
      #     expect {
      #       HelloJob.perform_later
      #       HeavyLiftingJob.perform_later
      #     }.to have_enqueued_job(HelloJob).and have_enqueued_job(HeavyLiftingJob)
      def have_enqueued_job(job = nil)
        ActiveJob::HaveEnqueuedJob.new(job)
      end
    end
  end
end
