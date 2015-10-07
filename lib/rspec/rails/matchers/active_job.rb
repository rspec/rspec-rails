require "active_job/base"

module RSpec
  module Rails
    module Matchers
      # Namespace for various implementations of ActiveJob features
      #
      # @api private
      module ActiveJob
        # @private
        class HaveEnqueuedJobs < RSpec::Matchers::BuiltIn::BaseMatcher
          def initialize(only)
            @only = only
            set_expected_number(:exactly, 1)
          end

          def matches?(proc)
            raise ArgumentError, "have_enqueued_jobs only supports block expectations" unless Proc === proc

            before_block_jobs_size = enqueued_jobs_size(@only)
            proc.call
            @in_block_jobs_size = enqueued_jobs_size(@only) - before_block_jobs_size

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

          def enqueued_jobs_size(only)
            if only.any?
              queue_adapter.enqueued_jobs.count { |job| only.include?(job.fetch(:job)) }
            else
              queue_adapter.enqueued_jobs.count
            end
          end

          def set_expected_number(relativity, count)
            @expectation_type = relativity
            @expected_number = case count
                               when Numeric then count
                               when :once then 1
                               when :twice then 2
                               when :thrice then 3
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
      #     }.to have_enqueued_jobs
      #
      #     expect {
      #       HelloJob.perform_later
      #       HeavyLiftingJob.perform_later
      #     }.to have_enqueued_jobs(HelloJob).exactly(:once)
      #
      #     expect {
      #       HelloJob.perform_later
      #       HelloJob.perform_later
      #       HelloJob.perform_later
      #     }.to have_enqueued_jobs(HelloJob).at_least(2).times
      #
      #     expect {
      #       HelloJob.perform_later
      #     }.to have_enqueued_jobs(HelloJob).at_most(:twice)
      def have_enqueued_jobs(*jobs)
        ActiveJob::HaveEnqueuedJobs.new(jobs)
      end
    end
  end
end
