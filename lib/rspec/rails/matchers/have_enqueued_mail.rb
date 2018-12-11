require "rspec/rails/matchers/active_job"

module RSpec
  module Rails
    module Matchers
      # @api private
      #
      # Matcher class for `have_enqueued_mail`. Should not be instantiated directly.
      #
      # @see RSpec::Rails::Matchers#have_enqueued_mail
      class HaveEnqueuedMail < RSpec::Matchers::BuiltIn::BaseMatcher
        def initialize(mailer_class, method_name)
          @mailer_class = mailer_class
          @method_name = method_name
          @args = []
        end

        def description
          "enqueues #{@mailer_class.name}.#{@method_name}"
        end

        def matches?(block)
          raise ArgumentError, 'have_enqueued_mail and enqueue_mail only work with block arguments' unless block.respond_to?(:call)
          check_active_job_adapter

          job_matcher = ActiveJob::HaveEnqueuedJob.new(ActionMailer::DeliveryJob)
          job_matcher.with(*mailer_args)
          job_matcher.matches?(block)
        end

        def with(*args)
          @args = args
          self
        end

        def failure_message
          base_message.tap do |msg|
            msg << " with #{@args}" if @args.any?
          end
        end

        def supports_block_expectations?
          true
        end

        private

        def base_message
          "expected to enqueue #{@mailer_class.name}.#{@method_name}"
        end

        def mailer_args
          [@mailer_class.name, @method_name.to_s, 'deliver_now'] + @args
        end

        def check_active_job_adapter
          return if ::ActiveJob::QueueAdapters::TestAdapter === ::ActiveJob::Base.queue_adapter
          raise StandardError, "To use HaveEnqueuedMail matcher set `ActiveJob::Base.queue_adapter = :test`"
        end
      end

      # @api public
      # Passes if an email has been enqueued inside block. May chain with to specify expected arguments.
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
      def have_enqueued_mail(mailer_class, mail_method_name)
        check_active_job_adapter
        HaveEnqueuedMail.new(mailer_class, mail_method_name)
      end
      alias_method :have_enqueued_email, :have_enqueued_mail
      alias_method :enqueue_mail, :have_enqueued_mail
      alias_method :enqueue_email, :have_enqueued_mail
    end
  end
end
