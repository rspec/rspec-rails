require 'action_controller'
require 'webrat'

module ControllerExampleGroupBehaviour
  extend ActiveSupport::Concern

  module AttributeReaders
    extend ActiveSupport::Concern
    attr_reader :controller

    module ClassMethods
      def controller_class
        describes
      end
    end
  end

  included do
    extend  RSpec::Rails::SetupAndTeardownAdapter
    include RSpec::Rails::TestUnitAssertionAdapter
    include ActionController::TestCase::Behavior
    include AttributeReaders
    include RSpec::Rails::ViewRendering
    include Webrat::Matchers
    include Webrat::Methods
    include RSpec::Matchers
    before do
      @routes = ::Rails.application.routes
      ActionController::Base.allow_forgery_protection = false
    end
  end

  RSpec.configure do |c|
    c.include self, :example_group => { :file_path => /\bspec\/controllers\// }
  end
end
