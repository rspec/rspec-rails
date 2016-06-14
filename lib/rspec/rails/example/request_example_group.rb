module RSpec
  module Rails
    # @api public
    # Container class for request spec functionality.
    module RequestExampleGroup
      extend ActiveSupport::Concern
      include RSpec::Rails::RailsExampleGroup
      include ActionDispatch::Integration::Runner
      include ActionDispatch::Assertions
      include RSpec::Rails::ResponseMatchers::RedirectTo
      include RSpec::Rails::ResponseMatchers::RenderTemplate
      include ActionController::TemplateAssertions

      begin
        include ActionDispatch::IntegrationTest::Behavior
      rescue NameError # rubocop:disable Lint/HandleExceptions
        # rails is too old to provide integration test helpers
      end

      # Delegates to `Rails.application`.
      def app
        ::Rails.application
      end

      included do
        before do
          @routes = ::Rails.application.routes
        end
      end
    end
  end
end
