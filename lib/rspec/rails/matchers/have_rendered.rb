module RSpec
  module Rails
    module Matchers
      # Matcher for template rendering.
      module RenderTemplate
        # @private
        class RenderTemplateMatcher < RSpec::Matchers::DSL::Matcher
          def initialize(name, scope, expected, message = nil)
            @message = message
            @scope = scope
            @expected = Symbol === expected ? expected.to_s : expected
            @rescued_exception = nil
            @redirect_is = nil

            declarations = lambda do |_|
              match do |_actual|
                match_check = match_unless_raises ActiveSupport::TestCase::Assertion do
                  scope.assert_template @expected, @message
                end
                check_redirect unless match_check
                match_check
              end

              failure_message do |_|
                if @redirect_is
                  @rescued_exception.message[/(.*?)( but|$)/, 1] +
                    " but was a redirect to <#{@redirect_is}>"
                else
                  @rescued_exception.message
                end
              end

              failure_message_when_negated do |_|
                "expected not to render #{@expected.inspect}, but did"
              end
            end
            super(name, declarations, scope, expected)
          end

          # matches unless a matcher raises one of a specified set of exceptions
          # @api private
          def match_unless_raises(*exceptions)
            exceptions.unshift Exception if exceptions.empty?
            begin
              yield
              true
            rescue *exceptions => @rescued_exception
              false
            end
          end

          # Uses normalize_argument_to_redirection to find and format
          # the redirect location. normalize_argument_to_redirection is private
          # in ActionDispatch::Assertions::ResponseAssertions so we call it
          # here using #send. This will keep the error message format consistent
          # @api private
          def check_redirect
            response = @scope.response
            return unless response.respond_to?(:redirect?) && response.redirect?
            @redirect_is = @scope.send(:normalize_argument_to_redirection, response.location)
          end
        end

        # Delegates to `assert_template`.
        #
        # @example
        #     expect(response).to have_rendered("new")
        def have_rendered(options, message = nil)
          RenderTemplateMatcher.new("have_rendered", self, options, message)
        end

        # Delegates to `assert_template`.
        #
        # @example
        #     expect(response).to render_template("new")
        def render_template(options, message = nil)
          RenderTemplateMatcher.new("render_template", self, options, message)
        end
      end
    end
  end
end
