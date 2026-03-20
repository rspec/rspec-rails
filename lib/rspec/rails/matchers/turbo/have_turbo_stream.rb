module RSpec
  module Rails
    module Matchers
      module Turbo
        # @private
        class HaveTurboStream < RSpec::Rails::Matchers::BaseMatcher
          def initialize(scope, action:, target: nil, targets: nil)
            @scope = scope
            @action = action.to_s
            @target = target&.to_s
            @targets = targets&.to_s
            @expected_count = nil

            if @target.nil? && @targets.nil?
              raise ArgumentError, "You must specify either :target or :targets"
            end

            if @target && @targets
              raise ArgumentError, "You cannot specify both :target and :targets"
            end
          end

          def with_count(count)
            @expected_count = Integer(count)
            self
          end

          def matches?(*)
            match_unless_raises ActiveSupport::TestCase::Assertion do
              if @expected_count
                @scope.assert_select turbo_stream_selector, count: @expected_count
              else
                @scope.assert_select turbo_stream_selector
              end
            end
          end

          def description
            desc = "have turbo stream \"#{@action}\" targeting "
            desc << (@target ? "\"#{@target}\"" : "\"#{@targets}\"")
            desc << " #{@expected_count} time(s)" if @expected_count
            desc
          end

          def failure_message
            rescued_exception.message
          end

          def failure_message_when_negated
            "expected response not to #{description}, but it was found"
          end

        private

          def css_escape(value)
            value.gsub('\\', '\\\\\\\\').gsub('"', '\\"')
          end

          def turbo_stream_selector
            selector = "turbo-stream[action=\"#{css_escape(@action)}\"]"
            if @target
              selector << "[target=\"#{css_escape(@target)}\"]"
            elsif @targets
              selector << "[targets=\"#{css_escape(@targets)}\"]"
            end
            selector
          end
        end

        # @private
        class BeTurboStream < RSpec::Matchers::BuiltIn::BaseMatcher
          TURBO_STREAM_MEDIA_TYPE = "text/vnd.turbo-stream.html".freeze

          def matches?(response)
            @response = response
            media_type(response) == TURBO_STREAM_MEDIA_TYPE
          end

          def does_not_match?(response)
            @response = response
            media_type(response) != TURBO_STREAM_MEDIA_TYPE
          end

          def description
            "be a Turbo Stream response"
          end

          def failure_message
            "expected response to be a Turbo Stream response " \
              "(media type \"#{TURBO_STREAM_MEDIA_TYPE}\"), " \
              "but got \"#{media_type(@response)}\""
          end

          def failure_message_when_negated
            "expected response not to be a Turbo Stream response, but it was"
          end

        private

          def media_type(response)
            if response.respond_to?(:media_type)
              response.media_type
            elsif response.respond_to?(:content_type)
              response.content_type.to_s.split(";").first&.strip
            end
          end
        end
      end
    end
  end
end
