require "rspec/mocks"
require "rspec/rails/matchers/active_job"

module RSpec
  module Rails
    module Matchers
      # Matcher class for `have_enqueued_mail`. Should not be instantiated directly.
      #
      # rubocop: disable Style/ClassLength
      # @private
      # @see RSpec::Rails::Matchers#have_enqueued_mail
      class HaveEnqueuedMail < ActiveJob::HaveEnqueuedJob
        MAILER_JOB_METHOD = 'deliver_now'.freeze

        include RSpec::Mocks::ExampleMethods

        def initialize(mailer_class, method_name)
          super(mailer_job)
          @mailer_class = mailer_class
          @method_name = method_name
          @mail_args = []
          @args = mailer_args
        end

        def description
          "enqueues #{@mailer_class.name}.#{@method_name}"
        end

        def with(*args, &block)
          @mail_args = args
          block.nil? ? super(*mailer_args) : super(*mailer_args, &yield_mail_args(block))
        end

        def matches?(block)
          raise ArgumentError, 'have_enqueued_mail and enqueue_mail only work with block arguments' unless block.respond_to?(:call)
          check_active_job_adapter
          super
        end

        def failure_message
          "expected to enqueue #{base_message}".tap do |msg|
            msg << "\n#{unmatching_mail_jobs_message}" if unmatching_mail_jobs.any?
          end
        end

        def failure_message_when_negated
          "expected not to enqueue #{base_message}"
        end

        private

        def base_message
          "#{@mailer_class.name}.#{@method_name}".tap do |msg|
            msg << " #{expected_count_message}"
            msg << " with #{@mail_args}," if @mail_args.any?
            msg << " on queue #{@queue}," if @queue
            msg << " at #{@at.inspect}," if @at
            msg << " but enqueued #{@matching_jobs.size}"
          end
        end

        def expected_count_message
          "#{message_expectation_modifier} #{@expected_number} #{@expected_number == 1 ? 'time' : 'times'}"
        end

        def mailer_args
          if @mail_args.any?
            base_mailer_args + @mail_args
          else
            mailer_method_arity = @mailer_class.instance_method(@method_name).arity

            number_of_args = if mailer_method_arity < 0
                               (mailer_method_arity + 1).abs
                             else
                               mailer_method_arity
                             end

            base_mailer_args + Array.new(number_of_args) { anything }
          end
        end

        def base_mailer_args
          [@mailer_class.name, @method_name.to_s, MAILER_JOB_METHOD]
        end

        def yield_mail_args(block)
          Proc.new { |*job_args| block.call(*(job_args - base_mailer_args)) }
        end

        def check_active_job_adapter
          return if ::ActiveJob::QueueAdapters::TestAdapter === ::ActiveJob::Base.queue_adapter
          raise StandardError, "To use HaveEnqueuedMail matcher set `ActiveJob::Base.queue_adapter = :test`"
        end

        def unmatching_mail_jobs
          @unmatching_jobs.select do |job|
            job[:job] == mailer_job
          end
        end

        def unmatching_mail_jobs_message
          msg = "Queued deliveries:"

          unmatching_mail_jobs.each do |job|
            msg << "\n  #{mail_job_message(job)}"
          end

          msg
        end

        def mail_job_message(job)
          mailer_method = job[:args][0..1].join('.')

          mailer_args = job[:args][3..-1]
          msg_parts = []
          msg_parts << "with #{mailer_args}" if mailer_args.any?
          msg_parts << "on queue #{job[:queue]}" if job[:queue] && job[:queue] != 'mailers'
          msg_parts << "at #{Time.at(job[:at])}" if job[:at]

          "#{mailer_method} #{msg_parts.join(', ')}".strip
        end

        def mailer_job
          ActionMailer::DeliveryJob
        end
      end
      # rubocop: enable Style/ClassLength

      # @api public
      # Passes if an email has been enqueued inside block.
      # May chain with to specify expected arguments.
      # May chain at_least, at_most or exactly to specify a number of times.
      # May chain at to specify a send time.
      # May chain on_queue to specify a queue.
      #
      # @example
      #     expect {
      #       MyMailer.welcome(user).deliver_later
      #     }.to have_enqueued_mail(MyMailer, :welcome)
      #
      #     # Using alias
      #     expect {
      #       MyMailer.welcome(user).deliver_later
      #     }.to enqueue_mail(MyMailer, :welcome)
      #
      #     expect {
      #       MyMailer.welcome(user).deliver_later
      #     }.to have_enqueued_mail(MyMailer, :welcome).with(user)
      #
      #     expect {
      #       MyMailer.welcome(user).deliver_later
      #       MyMailer.welcome(user).deliver_later
      #     }.to have_enqueued_mail(MyMailer, :welcome).at_least(:once)
      #
      #     expect {
      #       MyMailer.welcome(user).deliver_later
      #     }.to have_enqueued_mail(MyMailer, :welcome).at_most(:twice)
      #
      #     expect {
      #       MyMailer.welcome(user).deliver_later(wait_until: Date.tomorrow.noon)
      #     }.to have_enqueued_mail(MyMailer, :welcome).at(Date.tomorrow.noon)
      #
      #     expect {
      #       MyMailer.welcome(user).deliver_later(queue: :urgent_mail)
      #     }.to have_enqueued_mail(MyMailer, :welcome).on_queue(:urgent_mail)
      def have_enqueued_mail(mailer_class, mail_method_name)
        HaveEnqueuedMail.new(mailer_class, mail_method_name)
      end
      alias_method :have_enqueued_email, :have_enqueued_mail
      alias_method :enqueue_mail, :have_enqueued_mail
      alias_method :enqueue_email, :have_enqueued_mail
    end
  end
end
