require "rspec/rails/matchers/base_matcher"

module RSpec
  module Rails
    module Matchers
      # @api private
      class ErrorSubscriber
        attr_reader :events

        ErrorEvent = Struct.new(:error, :attributes)

        def initialize
          @events = []
        end

        def report(error, **attrs)
          @events << ErrorEvent.new(error, attrs.with_indifferent_access)
        end
      end

      # Matcher class for `have_reported_error`. Should not be instantiated directly.
      #
      # @api private
      # @see RSpec::Rails::Matchers#have_reported_error
      class HaveReportedError < RSpec::Rails::Matchers::BaseMatcher
        def initialize(expected_error = nil)
          @expected_error = expected_error
          @attributes = {}
          @error_subscriber = nil
        end

        def with_context(expected_attributes)
          @attributes.merge!(expected_attributes)
          self
        end

        def and(_)
          raise ArgumentError, "Chaining is not supported"
        end

        def matches?(block)
          if block.nil?
            raise ArgumentError, "this matcher doesn’t work with value expectations"
          end

          @error_subscriber = ErrorSubscriber.new
          ::Rails.error.subscribe(@error_subscriber)

          block.call

          return false if @error_subscriber.events.empty? && !@expected_error.nil?
          return false unless error_matches_expectation?

          return attributes_match_if_specified?
        ensure
          ::Rails.error.unsubscribe(@error_subscriber)
        end

        def supports_block_expectations?
          true
        end

        def description
          desc = "report an error"
          case @expected_error
          when Class
            desc = "report a #{@expected_error} error"
          when Exception
            desc = "report a #{@expected_error.class} error"
            desc += " with message '#{@expected_error.message}'" unless @expected_error.message.empty?
          when Regexp
            desc = "report an error with message matching #{@expected_error}"
          when Symbol
            desc = "report #{@expected_error}"
          end
          desc += " with #{@attributes}" unless @attributes.empty?
          desc
        end

        def failure_message
          if !@error_subscriber.events.empty? && !@attributes.empty?
            event_context = @error_subscriber.events.last.attributes[:context]
            unmatched = unmatched_attributes(event_context)
            unless unmatched.empty?
              return "Expected error attributes to match #{@attributes}, but got these mismatches: #{unmatched} and actual values are #{event_context}"
            end
          elsif @error_subscriber.events.empty?
            return 'Expected the block to report an error, but none was reported.'
          else
            case @expected_error
            when Class
              return "Expected error to be an instance of #{@expected_error}, but got #{actual_error.class} with message: '#{actual_error.message}'"
            when Exception
              return "Expected error to be #{@expected_error.class} with message '#{@expected_error.message}', but got #{actual_error.class} with message: '#{actual_error.message}'"
            when Regexp
              return "Expected error message to match #{@expected_error}, but got: '#{actual_error.message}'"
            when Symbol
              return "Expected error to be #{@expected_error}, but got: #{actual_error}"
            else
              return "Expected specific error, but got #{actual_error.class} with message: '#{actual_error.message}'"
            end
          end
        end

        def failure_message_when_negated
          error_count = @error_subscriber.events.count
          error_word = 'error'.pluralize(error_count)
          verb = error_count == 1 ? 'has' : 'have'

          "Expected the block not to report any errors, but #{error_count} #{error_word} #{verb} been reported."
        end

        private

        def error_matches_expectation?
          return true if @expected_error.nil? && @error_subscriber.events.any?

          case @expected_error
          when Class
            actual_error.is_a?(@expected_error)
          when Exception
            actual_error.is_a?(@expected_error.class) &&
              (@expected_error.message.empty? || actual_error.message == @expected_error.message)
          when Regexp
            actual_error.message&.match(@expected_error)
          when Symbol
            actual_error == @expected_error
          end
        end

        def attributes_match_if_specified?
          return true if @attributes.empty?
          return false if @error_subscriber.events.empty?

          event_context = @error_subscriber.events.last.attributes[:context]
          attributes_match?(event_context)
        end

        def actual_error
          @error_subscriber.events.empty? ? nil : @error_subscriber.events.last.error
        end

        def attributes_match?(actual)
          @attributes.all? do |key, value|
            if value.respond_to?(:matches?)
              value.matches?(actual[key])
            else
              actual[key] == value
            end
          end
        end

        def unmatched_attributes(actual)
          @attributes.reject do |key, value|
            if value.respond_to?(:matches?)
              value.matches?(actual[key])
            else
              actual[key] == value
            end
          end
        end
      end

      # @api public
      # Passes if the block reports an error to `Rails.error`.
      #
      # This matcher asserts that ActiveSupport::ErrorReporter has received an error report.
      #
      # @example Checking for any error
      #   expect { Rails.error.report(StandardError.new) }.to have_reported_error
      #
      # @example Checking for specific error class
      #   expect { Rails.error.report(MyError.new) }.to have_reported_error(MyError)
      #
      # @example Checking for specific error instance with message
      #   expect { Rails.error.report(MyError.new("message")) }.to have_reported_error(MyError.new("message"))
      #
      # @example Checking error attributes
      #   expect { Rails.error.report(StandardError.new, context: "test") }.to have_reported_error.with_context(context: "test")
      #
      # @example Checking error message patterns
      #   expect { Rails.error.report(StandardError.new("test message")) }.to have_reported_error(/test/)
      #
      # @example Negation
      #   expect { "safe code" }.not_to have_reported_error
      #
      # @param expected_error [Class, Exception, Regexp, Symbol, nil] the expected error to match
      def have_reported_error(expected_error = nil)
        HaveReportedError.new(expected_error)
      end

      alias_method :reports_error, :have_reported_error
    end
  end
end
