require "rspec/rails/matchers/active_job"

module RSpec
  module Rails
    module Matchers
      # Matcher class for `have_enqueued_mail`. Should not be instantiated directly.
      #
      # @private
      # @see RSpec::Rails::Matchers#have_enqueued_mail
      class HaveEnqueuedMail < RSpec::Matchers::BuiltIn::BaseMatcher
        include RSpec::Mocks::ExampleMethods

        def initialize(mailer_class, method_name)
          @mailer_class = mailer_class
          @method_name = method_name
          @args = []
          @at = nil
          @queue = nil
          @job_matcher = ActiveJob::HaveEnqueuedJob.new(ActionMailer::DeliveryJob)
          set_expected_count(:exactly, 1)
        end

        def description
          "enqueues #{@mailer_class.name}.#{@method_name}"
        end

        def matches?(block)
          raise ArgumentError, 'have_enqueued_mail and enqueue_mail only work with block arguments' unless block.respond_to?(:call)
          check_active_job_adapter

          @job_matcher.with(*mailer_args)
          @job_matcher.matches?(block)
        end

        def with(*args)
          @args = args
          self
        end

        def at(send_time)
          @at = send_time
          @job_matcher.at(send_time)
          self
        end

        def on_queue(queue)
          @queue = queue
          @job_matcher.on_queue(queue)
          self
        end

        %i[exactly at_least at_most].each do |method|
          define_method(method) do |count|
            @job_matcher.public_send(method, count)
            set_expected_count(method, count)
            self
          end
        end

        %i[once twice thrice].each do |method|
          define_method(method) do
            @job_matcher.public_send(method)
            exactly(method)
          end
        end

        def times
          self
        end

        def failure_message
          "expected to enqueue #{base_message}".tap do |msg|
            msg << "\n#{unmatching_mail_jobs_message}" if unmatching_mail_jobs.any?
          end
        end

        def failure_message_when_negated
          "expected not to enqueue #{base_message}"
        end

        def supports_block_expectations?
          true
        end

        private

        def base_message
          "#{@mailer_class.name}.#{@method_name}".tap do |msg|
            msg << " #{expected_count_message}"
            msg << " with #{@args}," if @args.any?
            msg << " on queue #{@queue}," if @queue
            msg << " at #{@at.inspect}," if @at
            msg << " but enqueued #{@job_matcher.matching_jobs.size}"
          end
        end

        def expected_count_message
          "#{@expected_count_type.to_s.tr('_', ' ')} #{@expected_count} #{@expected_count == 1 ? 'time' : 'times'}"
        end

        def mailer_args
          base_args = [@mailer_class.name, @method_name.to_s, 'deliver_now']

          if @args.any?
            base_args + @args
          else
            mailer_method_arity = @mailer_class.instance_method(@method_name).arity

            number_of_args = if mailer_method_arity.negative?
                               (mailer_method_arity + 1).abs
                             else
                               mailer_method_arity
                             end

            base_args + Array.new(number_of_args) { anything }
          end
        end

        def check_active_job_adapter
          return if ::ActiveJob::QueueAdapters::TestAdapter === ::ActiveJob::Base.queue_adapter
          raise StandardError, "To use HaveEnqueuedMail matcher set `ActiveJob::Base.queue_adapter = :test`"
        end

        def set_expected_count(relativity, count)
          @expected_count_type = relativity
          @expected_count = case count
                            when :once then 1
                            when :twice then 2
                            when :thrice then 3
                            else Integer(count)
                            end
        end

        def unmatching_mail_jobs
          @job_matcher.unmatching_jobs.select do |job|
            job[:job] == ActionMailer::DeliveryJob
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
        check_active_job_adapter
        HaveEnqueuedMail.new(mailer_class, mail_method_name)
      end
      alias_method :have_enqueued_email, :have_enqueued_mail
      alias_method :enqueue_mail, :have_enqueued_mail
      alias_method :enqueue_email, :have_enqueued_mail
    end
  end
end
