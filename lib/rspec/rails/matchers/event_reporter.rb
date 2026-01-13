# frozen_string_literal: true

module RSpec
  module Rails
    module Matchers
      # Container module for event reporter matchers.
      #
      # @api private
      module EventReporter
        # @api private
        # Wraps event data and provides matching logic.
        class Event
          # @api private
          # Returns the raw event data hash.
          attr_reader :event_data

          def initialize(event_data)
            @event_data = event_data
          end

          # @api private
          # Returns a human-readable representation of the event.
          def inspect
            "#{event_data[:name]} (payload: #{event_data[:payload].inspect}, tags: #{event_data[:tags].inspect}, context: #{event_data[:context].inspect})"
          end

          def matches?(name, payload = nil, tags = nil, context = nil)
            return false if name && resolve_name(name) != event_data[:name]
            return false if payload && !matches_payload?(payload)
            return false if tags && !matches_tags?(tags)
            return false if context && !matches_context?(context)

            true
          end

          private

          def resolve_name(name)
            case name
            when String, Symbol
              name.to_s
            when Class
              name.name
            else
              name.class.name
            end
          end

          def matches_payload?(expected_payload)
            matches_hash?(expected_payload, :payload, allow_regexp: true)
          end

          def matches_tags?(expected_tags)
            matches_hash?(expected_tags, :tags, allow_regexp: true)
          end

          def matches_context?(expected_context)
            matches_hash?(expected_context, :context, allow_regexp: true)
          end

          def matches_hash?(expected, key, allow_regexp:)
            actual = normalize_to_hash(event_data[key])
            return false unless actual.is_a?(Hash)

            expected.all? do |k, v|
              return false unless actual.key?(k)

              actual_value = actual[k]
              if allow_regexp && v.is_a?(Regexp)
                actual_value.to_s.match?(v)
              else
                actual_value == v
              end
            end
          end

          def normalize_to_hash(value)
            if value.respond_to?(:serialize)
              value.serialize
            else
              value
            end
          end
        end

        # @api private
        # Base class for event reporter matchers.
        class Base < RSpec::Rails::Matchers::BaseMatcher
          def initialize
            super()
            @expected_payload = nil
            @expected_tags = nil
            @expected_context = nil
          end

          def supports_value_expectations?
            false
          end

          def supports_block_expectations?
            true
          end

          # @api public
          # Specifies the expected payload.
          #
          # @param payload [Hash] expected payload keys and values
          # @return [self] self for chaining
          # @raise [ArgumentError] if payload is not a Hash
          def with_payload(payload)
            require_hash_argument(payload, :with_payload)
            @expected_payload = payload
            self
          end

          # @api public
          # Specifies the expected tags (supports Regexp values for matching).
          #
          # @param tags [Hash] expected tag keys and values (values can be Regexp)
          # @return [self] self for chaining
          # @raise [ArgumentError] if tags is not a Hash
          def with_tags(tags)
            require_hash_argument(tags, :with_tags)
            @expected_tags = tags
            self
          end

          # @api public
          # Specifies the expected context
          #
          # @param context [Hash] expected context keys and values (values can be regex)
          # @return [self] self for chaining
          # @raise [ArgumentError] if context is not a Hash
          def with_context(context)
            require_hash_argument(context, :with_context)
            @expected_context = context
            self
          end

          private

          def require_hash_argument(value, method_name)
            return if value.is_a?(Hash)

            raise ArgumentError, "#{method_name} requires a Hash, got #{value.class}"
          end

          def formatted_events
            @events.map { |e| "  #{e.inspect}" }.join("\n")
          end

          def format_event_criteria(name: nil, payload: nil, tags: nil, context: nil)
            parts = []
            parts << "name: #{name.inspect}" if name
            parts << "payload: #{payload.inspect}" if payload
            parts << "tags: #{tags.inspect}" if tags
            parts << "context: #{context.inspect}" if context
            parts.join(", ")
          end

          def find_matching_event(name: @expected_name, payload: @expected_payload, tags: @expected_tags, context: @expected_context)
            @events.find { |event| event.matches?(name, payload, tags, context) }
          end

          def record_events(&block)
            rails_events = ActiveSupport::Testing::EventReporterAssertions::EventCollector.record(&block)
            rails_events.map { |e| Event.new(e.event_data) }
          end
        end

        # @api private
        #
        # Matcher class for `have_reported_event`. Should not be instantiated directly.
        #
        # @see RSpec::Rails::Matchers#have_reported_event
        class HaveReportedEvent < Base
          def initialize(expected_name)
            super()
            @expected_name = expected_name
          end

          def matches?(block)
            @events = record_events(&block)

            if @events.empty?
              @failure_reason = :no_events
              return false
            end

            @matching_event = find_matching_event

            if @matching_event
              true
            else
              @failure_reason = :no_match
              false
            end
          end

          # @api private
          # Returns the failure message when the expectation is not met.
          def failure_message
            case @failure_reason
            when :no_events
              "expected an event to be reported, but there were no events reported"
            when :no_match
              <<~MSG.chomp
                expected an event to be reported matching:
                #{expectation_details}
                but none of the #{@events.size} reported events matched:
                #{formatted_events}
              MSG
            end
          end

          # @api private
          # Returns the failure message when the negated expectation is not met.
          def failure_message_when_negated
            if @expected_name
              "expected no event matching #{@expected_name.inspect} to be reported, but one was found"
            else
              "expected no event to be reported, but one was found"
            end
          end

          # @api private
          # Returns a description of the matcher.
          def description
            desc = "report event"
            desc += " #{@expected_name.inspect}" if @expected_name
            desc += " with payload #{@expected_payload.inspect}" if @expected_payload
            desc += " with tags #{@expected_tags.inspect}" if @expected_tags
            desc += " with context #{@expected_context.inspect}" if @expected_context
            desc
          end

          private

          def expectation_details
            details = []
            details << "  name: #{@expected_name.inspect}" if @expected_name
            details << "  payload: #{@expected_payload.inspect}" if @expected_payload
            details << "  tags: #{@expected_tags.inspect}" if @expected_tags
            details << "  context: #{@expected_context.inspect}" if @expected_context
            details.join("\n")
          end
        end

        # @api private
        #
        # Matcher class for `have_reported_no_event`. Should not be instantiated directly.
        #
        # @see RSpec::Rails::Matchers#have_reported_no_event
        class HaveReportedNoEvent < Base
          def initialize(expected_name = nil)
            super()
            @expected_name = expected_name
          end

          def matches?(block)
            @events = record_events(&block)

            if has_filters?
              @matching_event = find_matching_event
              @matching_event.nil?
            else
              @events.empty?
            end
          end

          # @api private
          # Returns the failure message when the expectation is not met.
          def failure_message
            if has_filters?
              <<~MSG.chomp
                expected no event matching #{match_description} to be reported, but found:
                  #{@matching_event.inspect}
              MSG
            else
              <<~MSG.chomp
                expected no events to be reported, but #{@events.size} events were reported:
                #{formatted_events}
              MSG
            end
          end

          # @api private
          # Returns the failure message when the negated expectation is not met.
          def failure_message_when_negated
            if has_filters?
              "expected an event matching #{match_description} to be reported, but none were found"
            else
              "expected at least one event to be reported, but none were"
            end
          end

          # @api private
          # Returns a description of the matcher.
          def description
            if has_filters?
              "report no event matching #{match_description}"
            else
              "report no events"
            end
          end

          private

          def has_filters?
            !!(@expected_name || @expected_payload || @expected_tags || @expected_context)
          end

          def match_description
            format_event_criteria(
              name: @expected_name,
              payload: @expected_payload,
              tags: @expected_tags,
              context: @expected_context
            )
          end
        end

        # @api private
        #
        # Matcher class for `have_reported_events`. Should not be instantiated directly.
        #
        # @see RSpec::Rails::Matchers#have_reported_events
        class HaveReportedEvents < Base
          def initialize(expected_events)
            super()
            @expected_events = expected_events
          end

          def matches?(block)
            @events = record_events(&block)

            @missing_events = find_missing_events

            if @missing_events.empty?
              true
            elsif @events.empty?
              @failure_reason = :no_events
              false
            else
              @failure_reason = :missing_events
              false
            end
          end

          # @api private
          # Returns the failure message when the expectation is not met.
          def failure_message
            case @failure_reason
            when :no_events
              "expected #{@expected_events.size} events to be reported, but there were no events reported"
            when :missing_events
              <<~MSG.chomp
                expected all events to be reported, but some were missing:
                #{formatted_missing_events}
                reported events:
                #{formatted_events}
              MSG
            end
          end

          # @api private
          # Returns the failure message when the negated expectation is not met.
          def failure_message_when_negated
            "expected events not to be reported, but all were found"
          end

          # @api private
          # Returns a description of the matcher.
          def description
            "report #{@expected_events.size} events"
          end

          private

          def find_missing_events
            remaining_events = @events.dup
            missing = []

            @expected_events.each do |expected|
              match_index = remaining_events.find_index do |event|
                event.matches?(expected[:name], expected[:payload], expected[:tags], expected[:context])
              end

              if match_index
                remaining_events.delete_at(match_index)
              else
                missing << expected
              end
            end

            missing
          end

          def formatted_missing_events
            @missing_events.map do |e|
              "  #{format_event_criteria(name: e[:name], payload: e[:payload], tags: e[:tags], context: e[:context])}"
            end.join("\n")
          end
        end
      end

      # @api public
      # Passes if the block reports an event matching the expected name.
      #
      # @example Basic usage
      #   expect { Rails.event.notify("user.created", { id: 123 }) }
      #     .to have_reported_event("user.created")
      #
      # @example With payload matching
      #   expect { Rails.event.notify("user.created", { id: 123, name: "John" }) }
      #     .to have_reported_event("user.created")
      #     .with_payload(id: 123)
      #
      # @example With tags matching (supports Regexp)
      #   expect {
      #     Rails.event.tagged(request_id: "abc123") do
      #       Rails.event.notify("user.created", { id: 123 })
      #     end
      #   }.to have_reported_event("user.created")
      #     .with_tags(request_id: /[a-z0-9]+/)
      #
      # @example With context matching
      #   Rails.event.set_context(request_id: "abc123")
      #   expect {
      #     Rails.event.notify("user.created", { id: 123 })
      #   }.to have_reported_event("user.created")
      #     .with_context(request_id: /[a-z0-9]+/)
      #
      # @param name [String, Symbol] the expected event name
      # @return [HaveReportedEvent]
      def have_reported_event(name = nil)
        EventReporter::HaveReportedEvent.new(name)
      end

      # @api public
      # Passes if the block reports no events (or no events matching the criteria).
      #
      # @example Basic usage - no events at all
      #   expect { }.to have_reported_no_event
      #
      # @example With specific event name
      #   expect { Rails.event.notify("other.event", {}) }
      #     .to have_reported_no_event("user.created")
      #
      # @example With payload filtering
      #   expect { Rails.event.notify("user.created", { id: 456 }) }
      #     .to have_reported_no_event("user.created")
      #     .with_payload(id: 123)
      #
      # @param name [String, Symbol, nil] the event name to filter (optional)
      # @return [HaveReportedNoEvent]
      def have_reported_no_event(name = nil)
        EventReporter::HaveReportedNoEvent.new(name)
      end

      # @api public
      # Passes if the block reports all specified events (order-agnostic).
      #
      # @example Basic usage
      #   expect {
      #     Rails.event.notify("user.created", { id: 123 })
      #     Rails.event.notify("email.sent", { to: "user@example.com" })
      #   }.to have_reported_events([
      #     { name: "user.created", payload: { id: 123 } },
      #     { name: "email.sent" }
      #   ])
      #
      # @example With tags matching (supports Regexp)
      #   expect {
      #     Rails.event.tagged(request_id: "123") do
      #       Rails.event.notify("user.created", { id: 123 })
      #       Rails.event.notify("email.sent", { to: "user@example.com" })
      #     end
      #   }.to have_reported_events([
      #     { name: "user.created", tags: { request_id: /\d+/ } },
      #     { name: "email.sent" }
      #   ])
      #
      # @param expected_events [Array<Hash>] array of expected event specifications
      #   Each hash can have :name, :payload, and :tags keys
      # @return [HaveReportedEvents]
      def have_reported_events(expected_events)
        EventReporter::HaveReportedEvents.new(expected_events)
      end

      # @api public
      # Temporarily enables debug mode for the event reporter within the block.
      # This allows debug events (reported via `Rails.event.debug`) to be captured
      # and tested.
      #
      # @example Testing debug events
      #   with_debug_event_reporting do
      #     expect {
      #       Rails.event.debug("debug.info", { data: "test" })
      #     }.to have_reported_event("debug.info")
      #   end
      #
      # @yield The block within which debug mode is enabled
      # @return [Object] the result of the block
      def with_debug_event_reporting(&block)
        ActiveSupport.event_reporter.with_debug(&block)
      end
    end
  end
end
