module RSpec::Rails
  # Extends ActionDispatch::Integration::Runner to work with RSpec.
  #
  # == Matchers
  #
  # In addition to the stock matchers from rspec-expectations, request
  # specs add these matchers, which delegate to rails' assertions:
  #
  #   response.should render_template(*args)
  #   => delegates to assert_template(*args)
  #
  #   response.should redirect_to(destination)
  #   => delegates to assert_redirected_to(destination)
  module RequestExampleGroup
    extend ActiveSupport::Concern
    extend RSpec::Rails::ModuleInclusion

    include ActionDispatch::Integration::Runner
    include RSpec::Rails::TestUnitAssertionAdapter
    include ActionDispatch::Assertions
    include Webrat::Matchers
    include Webrat::Methods
    include RSpec::Matchers
    include RSpec::Rails::Matchers::RedirectTo
    include RSpec::Rails::Matchers::RenderTemplate
    include ActionController::TemplateAssertions

    module InstanceMethods
      def app
        ::Rails.application
      end

      def last_response
        response
      end
    end

    included do
      metadata[:type] = :request

      before do
        @router = ::Rails.application.routes
      end

      Webrat.configure do |config|
        config.mode = :rack
      end
    end

    RSpec.configure &include_self_when_dir_matches('spec','requests')
  end
end
