require "active_support/testing/error_reporter_assertions"

module RSpec
  module Rails
    module Matchers
      ErrorCollector = ActiveSupport::Testing::ErrorReporterAssertions::ErrorCollector

      # Matcher class for `have_reported_error`. Should not be instantiated directly.
      #
      # Provides a way to test that an error was reported to Rails.error.
      #
      # @api private
      # @see RSpec::Rails::Matchers#have_reported_error
      class HaveReportedError < RSpec::Rails::Matchers::BaseMatcher
        # @param expected_error_or_message [Class, String, Regexp, nil]
        #   Error class, message string, or message pattern
        # @param expected_message [String, Regexp, nil]
        #   Expected message when first param is a class
        def initialize(expected_error_or_message, expected_message)
          @attributes = {}
          @warn_about_nil_error = expected_error_or_message.nil?

          case expected_error_or_message
          when UNDEFINED
            @expected_error = @expected_message = nil
          when String, Regexp
            @expected_error = nil
            @expected_message = expected_error_or_message
          else
            @expected_error = expected_error_or_message
            @expected_message = expected_message
          end
        end

        def with_context(expected_attributes)
          conflicting_keys = @attributes.keys & expected_attributes.keys
          unless conflicting_keys.empty?
            raise ArgumentError, "Attribute keys #{conflicting_keys.inspect} are already defined. " \
                                "Chaining with_context calls should not overwrite existing attributes. " \
                                "Use a single with_context call with all attributes instead."
          end
          @attributes.merge!(expected_attributes)
          self
        end

        def and(_)
          raise ArgumentError, "Chaining is not supported"
        end

        def or(_)
          raise ArgumentError, "Chaining is not supported"
        end

        def matches?(block)
          warn_about_nil_error! if @warn_about_nil_error

          capture_reports(block)

          !matching_report.nil?
        end

        def does_not_match?(block)
          warn_about_nil_error! if @warn_about_nil_error
          warn_about_negated_with_qualifiers! if has_qualifiers?

          capture_reports(block)

          matching_report.nil?
        end

        # @private
        def supports_block_expectations?
          true
        end

        # @private
        def supports_value_expectations?
          false
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

          attributes_desc = @attributes.empty? ? "" : " with context #{@attributes}"

          base_desc + message_desc + attributes_desc
        end

        def failure_message
          if @reports.empty?
            "Expected the block to report an error, but none was reported."
          elsif @attributes.any? && reports_matching_error_expectation.any?
            "Expected error attributes to match #{formatted(@attributes)}, but actual values are #{actual_context_values}"
          elsif @expected_error && @expected_message
            "Expected error to be an instance of #{@expected_error} #{expected_message_requirement}, but got: #{reported_errors}"
          elsif @expected_error
            "Expected error to be an instance of #{@expected_error}, but got: #{reported_errors}"
          elsif @expected_message.is_a?(Regexp)
            "Expected error message to match #{@expected_message}, but got: #{reported_errors}"
          elsif @expected_message.is_a?(String)
            "Expected error message to be '#{@expected_message}', but got: #{reported_errors}"
          else
            "Expected specific error, but got: #{reported_errors}"
          end
        end

        def failure_message_when_negated
          error_count = @reports.count
          error_word = "error".pluralize(error_count)
          verb = (error_count == 1) ? "has" : "have"

          "Expected the block not to report any errors, but #{error_count} #{error_word} #{verb} been reported."
        end

        private

        def capture_reports(block)
          @matching_report = nil
          @reports_matching_error_expectation = nil
          @reports = ErrorCollector.record(&block)
        end

        def reports_matching_error_expectation
          @reports_matching_error_expectation ||= @reports.select do |report|
            report_matches_error_expectation?(report)
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
            error.message.match(@expected_message)
          when String
            error.message == @expected_message
          else
            false
          end
        end

        def matching_report
          @matching_report ||= @reports.find do |report|
            report_matches_expectation?(report)
          end
        end

        def report_matches_expectation?(report)
          report_matches_error_expectation?(report) && attributes_match?(report.context)
        end

        def report_matches_error_expectation?(report)
          error_class_matches?(report.error) && error_message_matches?(report.error)
        end

        def attributes_match?(actual)
          return true if @attributes.empty?
          return false unless actual.is_a?(Hash)

          @attributes.all? do |key, value|
            actual.key?(key) && values_match?(value, actual[key])
          end
        end

        def actual_context_values
          contexts = reports_matching_error_expectation.map(&:context)
          formatted(contexts.one? ? contexts.first : contexts)
        end

        def expected_message_requirement
          case @expected_message
          when Regexp
            "with message matching #{@expected_message}"
          when String
            "with message '#{@expected_message}'"
          end
        end

        def reported_errors
          @reports.map do |report|
            "#{report.error.class}: '#{report.error.message}'"
          end.join(", ")
        end

        def formatted(object)
          improve_hash_formatting(RSpec::Support::ObjectFormatter.format(object))
        end

        def warn_about_nil_error!
          RSpec.warn_with("Using the `have_reported_error` matcher with a `nil` error is probably " \
                         "unintentional, it risks false positives, since `have_reported_error` " \
                         "will match when any error is reported to Rails.error, potentially " \
                         "allowing the expectation to pass without the specific error you are " \
                         "intending to test for being reported. " \
                         "Instead consider providing a specific error class or message. " \
                         "This message can be suppressed by setting: " \
                         "`RSpec::Expectations.configuration.on_potential_false" \
                         "_positives = :nothing`")
        end

        def warn_about_negated_with_qualifiers!
          RSpec.warn_with("Using `expect { }.not_to have_reported_error(error_class_or_message)` " \
                         "or with `.with_context()` is prone to false positives, since any error " \
                         "that doesn't match the specific error class, message, or context can " \
                         "cause the expectation to pass. Instead consider using " \
                         "`expect { }.not_to have_reported_error` with no qualifiers to ensure " \
                         "that no errors are reported at all.")
        end

        def has_qualifiers?
          !@expected_error.nil? || !@expected_message.nil? || @attributes.any?
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
      def have_reported_error(expected_error_or_message = HaveReportedError::UNDEFINED, expected_message = nil)
        HaveReportedError.new(expected_error_or_message, expected_message)
      end

      alias_method :reports_error, :have_reported_error
    end
  end
end
