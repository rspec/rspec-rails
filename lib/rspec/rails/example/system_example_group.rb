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

        def method_name
          [
            self.class.name.underscore,
            RSpec.current_example.description.underscore
          ].join("_").gsub(%r{[/\.:, ]}, "_")
        end

        # Delegates to `Rails.application`.
        def app
          ::Rails.application
        end

        included do
          attr_reader :driver

          def initialize(*args, &blk)
            super(*args, &blk)
            @driver = nil
          end

          def driven_by(*args, &blk)
            @driver = ::ActionDispatch::SystemTestCase.driven_by(*args, &blk).tap(&:use)
          end

          before do
            # A user may have already set the driver, so only default if driver
            # is not set
            driven_by(:selenium) unless @driver
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
