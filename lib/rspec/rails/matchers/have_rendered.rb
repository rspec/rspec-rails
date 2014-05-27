module RSpec::Rails::Matchers
  # Matcher for template rendering.
  module RenderTemplate
    # @private
    class RenderTemplateMatcher < RSpec::Matchers::BuiltIn::BaseMatcher

      def initialize(scope, expected, message=nil)
        @expected = Symbol === expected ? expected.to_s : expected
        @message = message
        @scope = scope
      end

      # @api private
      def matches?(*)
        match_unless_raises ActiveSupport::TestCase::Assertion do
          @scope.assert_template expected, @message
        end
      end

      # @api private
      def failure_message
        rescued_exception.message
      end

      # @api private
      def failure_message_when_negated
        "expected not to render #{expected.inspect}, but did"
      end
    end

    # Delegates to `assert_template`.
    #
    # @example
    #     expect(response).to have_rendered("new")
    def have_rendered(options, message=nil)
      RenderTemplateMatcher.new(self, options, message)
    end

    alias_method :render_template, :have_rendered
  end
end
