# We require the minimum amount of rspec-mocks possible to avoid
# conflicts with other mocking frameworks.
# See: https://github.com/rspec/rspec-rails/issues/2252
require "rspec/mocks/argument_matchers"
require "rspec/rails/matchers/active_job"

module RSpec
  module Rails
    module Matchers
      # rubocop: disable Metrics/ClassLength
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
              base_mailer_args + process_arguments(job, @mail_args)
            elsif @mailer_class && @method_name
              base_mailer_args + [any_args]
            elsif @mailer_class
              [mailer_class_name, any_args]
            else
              []
            end

          super(job)
        end

        def process_arguments(job, given_mail_args)
          # Old matcher behavior working with all builtin classes but ActionMailer::MailDeliveryJob
          return given_mail_args if use_given_mail_args?(job)

          # If matching args starts with a hash and job instance has params match with them
          if given_mail_args.first.is_a?(Hash) && job[:args][3]['params'].present?
            [hash_including(params: given_mail_args[0], args: given_mail_args.drop(1))]
          else
            [hash_including(args: given_mail_args)]
          end
        end

        def use_given_mail_args?(job)
          return true if defined?(ActionMailer::Parameterized::DeliveryJob) && job[:job] <= ActionMailer::Parameterized::DeliveryJob
          return false if rails_6_1_and_ruby_3_1?

          !(defined?(ActionMailer::MailDeliveryJob) && job[:job] <= ActionMailer::MailDeliveryJob)
        end

        def rails_6_1_and_ruby_3_1?
          return false unless RUBY_VERSION >= "3.1"
          return false unless ::Rails::VERSION::STRING >= '6.1'

          ::Rails::VERSION::STRING < '7'
        end

        def base_mailer_args
          [mailer_class_name, @method_name.to_s, MAILER_JOB_METHOD]
        end

        def yield_mail_args(block)
          proc do |*job_args|
            mailer_args = job_args - base_mailer_args
            if mailer_args.first.is_a?(Hash)
              block.call(*mailer_args.first[:args])
            else
              block.call(*mailer_args)
            end
          end
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
          mailer_args = deserialize_arguments(job)[3..-1]
          mailer_args = mailer_args.first[:args] if unified_mail?(job)
          msg_parts = []
          display_args = display_mailer_args(mailer_args)
          msg_parts << "with #{display_args}" if display_args.any?
          msg_parts << "on queue #{job[:queue]}" if job[:queue] && job[:queue] != 'mailers'
          msg_parts << "at #{Time.at(job[:at])}" if job[:at]

          "#{mailer_method} #{msg_parts.join(', ')}".strip
        end

        def display_mailer_args(mailer_args)
          return mailer_args unless mailer_args.first.is_a?(Hash) && mailer_args.first.key?(:args)

          mailer_args.first[:args]
        end

        def legacy_mail?(job)
          RSpec::Rails::FeatureCheck.has_action_mailer_legacy_delivery_job? && job[:job] <= ActionMailer::DeliveryJob
        end

        def parameterized_mail?(job)
          RSpec::Rails::FeatureCheck.has_action_mailer_parameterized? && job[:job] <= ActionMailer::Parameterized::DeliveryJob
        end

        def unified_mail?(job)
          RSpec::Rails::FeatureCheck.has_action_mailer_unified_delivery? && job[:job] <= ActionMailer::MailDeliveryJob
        end
      end
      # rubocop: enable Metrics/ClassLength

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
