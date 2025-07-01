module RSpec
  module Rails
    module Matchers
      # @api private
      # Sentinel value to distinguish between no argument passed vs explicitly passed nil.
      # This follows the same pattern as RSpec's raise_error matcher.
      UndefinedValue = Object.new.freeze

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
      # Provides a way to test that an error was reported to Rails.error.
      #
      # @api private
      # @see RSpec::Rails::Matchers#have_reported_error
      class HaveReportedError < RSpec::Rails::Matchers::BaseMatcher
        # Uses UndefinedValue as default to distinguish between no argument
        # passed vs explicitly passed nil.
        #
        # @param expected_error_or_message [Class, String, Regexp, nil]
        #   Error class, message string, or message pattern
        # @param expected_message [String, Regexp, nil]
        #   Expected message when first param is a class
        def initialize(expected_error_or_message = UndefinedValue, expected_message = nil)
          @attributes = {}

          case expected_error_or_message
          when nil, UndefinedValue
            @expected_error = nil
            @expected_message = expected_message
          when String, Regexp
            @expected_error = nil
            @expected_message = expected_error_or_message
          else
            @expected_error = expected_error_or_message
            @expected_message = expected_message
          end
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
            raise ArgumentError, "this matcher doesn't work with value expectations"
          end

          @error_subscriber = ErrorSubscriber.new
          ::Rails.error.subscribe(@error_subscriber)

          block.call

          return false if @error_subscriber.events.empty?
          return false unless error_matches_expectation?

          return attributes_match_if_specified?
        ensure
          ::Rails.error.unsubscribe(@error_subscriber)
        end

        def supports_block_expectations?
          true
        end

        def description
          base_desc = if @expected_error
                        "report a #{@expected_error} error"
                      else
                        "report an error"
                      end

          message_desc = if @expected_message
                           case @expected_message
                           when Regexp
                             " with message matching #{@expected_message}"
                           when String
                             " with message '#{@expected_message}'"
                           end
                         else
                           ""
                         end

          attributes_desc = @attributes.empty? ? "" : " with #{@attributes}"

          base_desc + message_desc + attributes_desc
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
          elsif actual_error.nil?
            reported_errors = @error_subscriber.events.map { |event| "#{event.error.class}: '#{event.error.message}'" }.join(', ')
            if @expected_error && @expected_message
              return "Expected error to be an instance of #{@expected_error} with message '#{@expected_message}', but got: #{reported_errors}"
            elsif @expected_error
              return "Expected error to be an instance of #{@expected_error}, but got: #{reported_errors}"
            elsif @expected_message.is_a?(Regexp)
              return "Expected error message to match #{@expected_message}, but got: #{reported_errors}"
            elsif @expected_message.is_a?(String)
              return "Expected error message to be '#{@expected_message}', but got: #{reported_errors}"
            end
          else
            if @expected_error && !actual_error.is_a?(@expected_error)
              return "Expected error to be an instance of #{@expected_error}, but got #{actual_error.class} with message: '#{actual_error.message}'"
            elsif @expected_message
              return "Expected error message to #{@expected_message.is_a?(Regexp) ? "match" : "be" } #{@expected_message}, but got: '#{actual_error.message}'"
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
          return true if @expected_error.nil? && @expected_message.nil? && @error_subscriber.events.count.positive?

          @error_subscriber.events.any? do |event|
            error_class_matches?(event.error) && error_message_matches?(event.error)
          end
        end

        def error_class_matches?(error)
          @expected_error.nil? || error.is_a?(@expected_error)
        end

        # Check if the given error message matches the expected message pattern
        def error_message_matches?(error)
          return true if @expected_message.nil?

          case @expected_message
          when Regexp
            error.message&.match(@expected_message)
          when String
            error.message == @expected_message
          else
            false
          end
        end

        def attributes_match_if_specified?
          return true if @attributes.empty?
          return false unless matching_event

          event_context = matching_event.attributes[:context]
          attributes_match?(event_context)
        end

        def actual_error
          @actual_error ||= matching_event&.error
        end

        def matching_event
          @matching_event ||= find_matching_event
        end

        def find_matching_event
          @error_subscriber.events.find do |event|
            error_class_matches?(event.error) && error_message_matches?(event.error)
          end
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
      # @example Checking for specific error class with message
      #   expect { Rails.error.report(MyError.new("message")) }.to have_reported_error(MyError, "message")
      #
      # @example Checking for error with exact message (any class)
      #   expect { Rails.error.report(StandardError.new("exact message")) }.to have_reported_error("exact message")
      #
      # @example Checking for error with message pattern (any class)
      #   expect { Rails.error.report(StandardError.new("test message")) }.to have_reported_error(/test/)
      #
      # @example Checking for specific error class with message pattern
      #   expect { Rails.error.report(StandardError.new("test message")) }.to have_reported_error(StandardError, /test/)
      #
      # @example Checking error attributes
      #   expect { Rails.error.report(StandardError.new, context: "test") }.to have_reported_error.with_context(context: "test")
      #
      # @example Negation
      #   expect { "safe code" }.not_to have_reported_error
      #
      # @param expected_error_or_message [Class, String, Regexp, nil] the expected error class, message string, or message pattern
      # @param expected_message [String, Regexp, nil] the expected error message to match
      def have_reported_error(expected_error_or_message = UndefinedValue, expected_message = nil)
        HaveReportedError.new(expected_error_or_message, expected_message)
      end

      alias_method :reports_error, :have_reported_error
    end
  end
end
