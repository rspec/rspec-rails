# We require the minimum amount of rspec-mocks possible to avoid
# conflicts with other mocking frameworks.
# See: https://github.com/rspec/rspec-rails/issues/2252
require "rspec/mocks/argument_matchers"
require "rspec/rails/matchers/active_job"

module RSpec
  module Rails
    module Matchers
      # Matcher class for `have_enqueued_mail`. Should not be instantiated directly.
      #
      # @private
      # @see RSpec::Rails::Matchers#have_enqueued_mail
      class HaveEnqueuedMail < ActiveJob::HaveEnqueuedJob
        MAILER_JOB_METHOD = 'deliver_now'.freeze

        include RSpec::Mocks::ArgumentMatchers

        def initialize(mailer_class, method_name)
          super(nil)
          @mailer_class = mailer_class
          @method_name = method_name
          @mail_args = []
        end

        def description
          "enqueues #{mailer_class_name}.#{@method_name}"
        end

        def with(*args, &block)
          @mail_args = args
          block.nil? ? super : super(&yield_mail_args(block))
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
          [mailer_class_name, @method_name].compact.join('.').tap do |msg|
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

        def mailer_class_name
          @mailer_class ? @mailer_class.name : 'ActionMailer::Base'
        end

        def job_match?(job)
          legacy_mail?(job) || parameterized_mail?(job) || unified_mail?(job)
        end

        def arguments_match?(job)
          @args =
            if @mail_args.any?
              base_mailer_args + @mail_args
            elsif @mailer_class && @method_name
              base_mailer_args + [any_args]
            elsif @mailer_class
              [mailer_class_name, any_args]
            else
              []
            end

          super(job)
        end

        def base_mailer_args
          [mailer_class_name, @method_name.to_s, MAILER_JOB_METHOD]
        end

        def yield_mail_args(block)
          proc { |*job_args| block.call(*(job_args - base_mailer_args)) }
        end

        def check_active_job_adapter
          return if ::ActiveJob::QueueAdapters::TestAdapter === ::ActiveJob::Base.queue_adapter

          raise StandardError, "To use HaveEnqueuedMail matcher set `ActiveJob::Base.queue_adapter = :test`"
        end

        def unmatching_mail_jobs
          @unmatching_jobs.select do |job|
            job_match?(job)
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

        def legacy_mail?(job)
          job[:job] <= ActionMailer::DeliveryJob
        end

        def parameterized_mail?(job)
          RSpec::Rails::FeatureCheck.has_action_mailer_parameterized? && job[:job] <= ActionMailer::Parameterized::DeliveryJob
        end

        def unified_mail?(job)
          RSpec::Rails::FeatureCheck.has_action_mailer_unified_delivery? && job[:job] <= ActionMailer::MailDeliveryJob
        end
      end
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
      #     }.to have_enqueued_mail
      #
      #     expect {
      #       MyMailer.welcome(user).deliver_later
      #     }.to have_enqueued_mail(MyMailer)
      #
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
      def have_enqueued_mail(mailer_class = nil, mail_method_name = nil)
        HaveEnqueuedMail.new(mailer_class, mail_method_name)
      end
      alias_method :have_enqueued_email, :have_enqueued_mail
      alias_method :enqueue_mail, :have_enqueued_mail
      alias_method :enqueue_email, :have_enqueued_mail
    end
  end
end
