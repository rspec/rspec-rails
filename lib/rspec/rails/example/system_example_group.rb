if ActionPack::VERSION::STRING >= "5.1"
  require 'action_dispatch/system_test_case'
  module RSpec
    module Rails
      # @api public
      # Container class for system tests
      module SystemExampleGroup
        extend ActiveSupport::Concern
        include RSpec::Rails::RailsExampleGroup
        include ActionDispatch::Integration::Runner
        include ActionDispatch::Assertions
        include RSpec::Rails::Matchers::RedirectTo
        include RSpec::Rails::Matchers::RenderTemplate
        include ActionController::TemplateAssertions

        include ActionDispatch::IntegrationTest::Behavior

        # @private
        module BlowAwayAfterTeardownHook
          # @private
          def after_teardown
          end
        end

        original_after_teardown = ::ActionDispatch::SystemTesting::TestHelpers::SetupAndTeardown.instance_method(:after_teardown)

        include ::ActionDispatch::SystemTesting::TestHelpers::SetupAndTeardown
        include ::ActionDispatch::SystemTesting::TestHelpers::ScreenshotHelper
        include BlowAwayAfterTeardownHook

        # for the SystemTesting Screenshot situation
        def passed?
          RSpec.current_example.exception.nil?
        end

        # Delegates to `Rails.application`.
        def app
          ::Rails.application
        end

        included do
          attr_reader :driver
          def driven_by(*args, &blk)
            @driver = ::ActionDispatch::SystemTestCase.driven_by(*args, &blk).tap(&:use)
          end

          before do
            driven_by(:selenium)
            @routes = ::Rails.application.routes
          end

          after do
            original_after_teardown.bind(self).call
          end
        end
      end
    end
  end
end
