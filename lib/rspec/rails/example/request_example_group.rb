module RSpec::Rails
  module RequestExampleGroup
    extend ActiveSupport::Concern
    include RSpec::Rails::RailsExampleGroup
    include ActionDispatch::Integration::Runner
    include ActionDispatch::Assertions
    include RSpec::Rails::Matchers::RedirectTo
    include RSpec::Rails::Matchers::RenderTemplate
    include ActionController::TemplateAssertions

    def app
      RSpec.configuration.application
    end

    included do
      metadata[:type] = :request

      before do
        @routes = RSpec.configuration.application.routes
      end
    end
  end
end
