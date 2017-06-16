if ActionPack::VERSION::STRING >= "5.1"
  require 'action_dispatch/system_test_case'
  module RSpec
    module Rails
      # @api public
      # Container class for request spec functionality.
      module SystemExampleGroup
        # In rails system test inherits from integration test.
        # RequestExampleGroup wraps that, so we just include it here
        include RSpec::Rails::RequestExampleGroup

        original_after_teardown = ::ActionDispatch::SystemTesting::TestHelpers::SetupAndTeardown.instance_method(:after_teardown)

        module SystemTestHooks
          include ::ActionDispatch::SystemTesting::TestHelpers::SetupAndTeardown
          include ::ActionDispatch::SystemTesting::TestHelpers::ScreenshotHelper
          # for the SystemTesting Screenshot situation
          def passed?
            RSpec.current_example.exception.nil?
          end

          def after_teardown
          end
        end
        include SystemTestHooks

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
