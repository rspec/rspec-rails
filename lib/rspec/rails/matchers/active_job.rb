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
          def initialize(number, only = nil)
            @number = number
            @only   = only
          end

          def matches?(proc)
            raise ArgumentError, "have_enqueued_jobs only supports block expectations" unless Proc === proc

            before_block_jobs_size = enqueued_jobs_size(@only)
            proc.call
            @in_block_jobs_size = enqueued_jobs_size(@only) - before_block_jobs_size
            @number == @in_block_jobs_size
          end

          def failure_message
            "expected to enqueue #{@number} jobs, but enqueued #{@in_block_jobs_size}"
          end

          def failure_message_when_negated
            "expected not to enqueue #{@number} jobs, but enqueued #{@in_block_jobs_size}"
          end

          def supports_block_expectations?
            true
          end

        private

          def enqueued_jobs_size(only)
            if only
              queue_adapter.enqueued_jobs.count { |job| Array(only).include?(job.fetch(:job)) }
            else
              queue_adapter.enqueued_jobs.count
            end
          end

          def queue_adapter
            ::ActiveJob::Base.queue_adapter
          end
        end
      end

      # @api public
      # Passess if `number` of jobs were enqueued inside block
      #
      # @example
      #     expect {
      #       HeavyLiftingJob.perform_later
      #     }.to have_enqueued_jobs(1)
      #
      #     expect {
      #       HelloJob.perform_later
      #       HeavyLiftingJob.perform_later
      #     }.to have_enqueued_jobs(1, only: HelloJob)
      def have_enqueued_jobs(number = 1, options = {})
        only = options[:only]
        ActiveJob::HaveEnqueuedJobs.new(number, only)
      end
    end
  end
end
