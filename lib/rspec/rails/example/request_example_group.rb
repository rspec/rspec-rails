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
      if Gem::Version.new(Rails.version) >= Gem::Version.new('3.1.0')
        return RSpec.configuration.application
      else
        return ::Rails.application
      end
    end

    included do
      metadata[:type] = :request

      before do
        if Gem::Version.new(Rails.version) >= Gem::Version.new('3.1.0')
          @routes = RSpec.configuration.application.routes
        else
          @routes = ::Rails.application.routes
        end
      end
    end
  end
end
