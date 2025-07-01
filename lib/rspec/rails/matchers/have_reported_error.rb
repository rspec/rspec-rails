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
        def initialize(expected_error_class = nil, expected_message = nil)
          # Handle backward compatibility with old API
          if expected_error_class.is_a?(Exception)
            @expected_error_class = expected_error_class.class
            @expected_message = expected_error_class.message.empty? ? nil : expected_error_class.message
          elsif expected_error_class.is_a?(Regexp)
            @expected_error_class = nil
            @expected_message = expected_error_class
          elsif expected_error_class.is_a?(Symbol)
            @expected_error_symbol = expected_error_class
            @expected_error_class = nil
            @expected_message = nil
          else
            @expected_error_class = expected_error_class
            @expected_message = expected_message
            @expected_error_symbol = nil
          end
          
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
          desc = "report an error"
          if @expected_error_symbol
            desc = "report #{@expected_error_symbol}"
          elsif @expected_error_class
            desc = "report a #{@expected_error_class} error"
          end
          if @expected_message
            case @expected_message
            when Regexp
              desc += " with message matching #{@expected_message}"
            when String
              desc += " with message '#{@expected_message}'"
            end
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
            if @expected_error_symbol
              return "Expected error to be #{@expected_error_symbol}, but got: #{actual_error}"
            elsif @expected_error_class && !actual_error.is_a?(@expected_error_class)
              return "Expected error to be an instance of #{@expected_error_class}, but got #{actual_error.class} with message: '#{actual_error.message}'"
            elsif @expected_message
              case @expected_message
              when Regexp
                return "Expected error message to match #{@expected_message}, but got: '#{actual_error.message}'"
              when String
                return "Expected error message to be '#{@expected_message}', but got: '#{actual_error.message}'"
              end
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
          # If no events were reported, we can't match anything
          return false if @error_subscriber.events.empty?
          
          # Handle symbol matching (backward compatibility)
          if @expected_error_symbol
            return actual_error == @expected_error_symbol
          end
          
          # If no constraints are given, any error should match
          return true if @expected_error_class.nil? && @expected_message.nil?

          class_matches = @expected_error_class.nil? || actual_error.is_a?(@expected_error_class)
          
          message_matches = if @expected_message.nil?
            true
          elsif @expected_message.is_a?(Regexp)
            actual_error.message&.match(@expected_message)
          elsif @expected_message.is_a?(String)
            actual_error.message == @expected_message
          else
            false
          end

          class_matches && message_matches
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
      # @example Checking for specific error class with message
      #   expect { Rails.error.report(MyError.new("message")) }.to have_reported_error(MyError, "message")
      #
      # @example Checking for specific error instance (backward compatibility)
      #   expect { Rails.error.report(MyError.new("message")) }.to have_reported_error(MyError.new("message"))
      #
      # @example Checking error attributes
      #   expect { Rails.error.report(StandardError.new, context: "test") }.to have_reported_error.with_context(context: "test")
      #
      # @example Checking error message patterns
      #   expect { Rails.error.report(StandardError.new("test message")) }.to have_reported_error(StandardError, /test/)
      #   expect { Rails.error.report(StandardError.new("test message")) }.to have_reported_error(/test/)
      #
      # @example Negation
      #   expect { "safe code" }.not_to have_reported_error
      #
      # @param expected_error_class [Class, Exception, Regexp, Symbol, nil] the expected error class to match, or error instance for backward compatibility
      # @param expected_message [String, Regexp, nil] the expected error message to match
      def have_reported_error(expected_error_class = nil, expected_message = nil)
        HaveReportedError.new(expected_error_class, expected_message)
      end

      alias_method :reports_error, :have_reported_error
    end
  end
end
