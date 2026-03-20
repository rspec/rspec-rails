module RSpec
  module Rails
    module Matchers
      module Turbo
        # @private
        class HaveTurboFrame < RSpec::Rails::Matchers::BaseMatcher
          def initialize(scope, id)
            @scope = scope
            @id = id.to_s
          end

          def matches?(*)
            match_unless_raises ActiveSupport::TestCase::Assertion do
              @scope.assert_select turbo_frame_selector
            end
          end

          def description
            "have turbo frame \"#{@id}\""
          end

          def failure_message
            rescued_exception.message
          end

          def failure_message_when_negated
            "expected response not to have a <turbo-frame> with id \"#{@id}\", but it was found"
          end

        private

          def css_escape(value)
            value.gsub('\\', '\\\\\\\\').gsub('"', '\\"')
          end

          def turbo_frame_selector
            "turbo-frame[id=\"#{css_escape(@id)}\"]"
          end
        end
      end
    end
  end
end
