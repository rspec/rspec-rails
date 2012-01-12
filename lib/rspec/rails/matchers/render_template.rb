module RSpec::Rails::Matchers
  module RenderTemplate
    class RenderTemplateMatcher
      include RSpec::Matchers::BuiltIn::BaseMatcher

      def initialize(scope, expected, message=nil)
        super(Symbol === expected ? expected.to_s : expected)
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
      def failure_message_for_should
        rescued_exception.message
      end

      # @api private
      def failure_message_for_should_not
        "expected not to render #{expected.inspect}, but did"
      end
    end

    # Delegates to `assert_template`
    #
    # @example
    #
    #     response.should render_template("new")
    def render_template(options, message=nil)
      RenderTemplateMatcher.new(self, options, message)
    end
  end
end
