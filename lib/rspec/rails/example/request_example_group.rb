module RSpec::Rails
  module RequestExampleGroup
    extend ActiveSupport::Concern
    include RSpec::Rails::RailsExampleGroup
    include ActionDispatch::Integration::Runner
    include ActionDispatch::Assertions

    module InstanceMethods
      def app
        ::Rails.application
      end
    end

    include RSpec::Rails::Matchers::RedirectTo
    include RSpec::Rails::Matchers::RenderTemplate
    include ActionController::TemplateAssertions

    included do
      metadata[:type] = :request

      before do
        @routes = ::Rails.application.routes
      end
    end
  end
end
