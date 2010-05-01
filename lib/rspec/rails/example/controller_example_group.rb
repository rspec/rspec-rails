require 'action_controller'
require 'webrat'

module ControllerExampleGroupBehaviour
  extend ActiveSupport::Concern

  module ClassAttributeReaders
    def controller_class
      describes
    end
  end

  module AttributeReaders
    attr_reader :controller
  end

  included do
    extend  Rspec::Rails::SetupAndTeardownAdapter
    include Rspec::Rails::TestUnitAssertionAdapter
    include ActionController::TestCase::Behavior
    extend  ClassAttributeReaders
    include AttributeReaders
    include Webrat::Matchers
    include Webrat::Methods
    include Rspec::Matchers
    before do
      @routes = ::Rails.application.routes
      @_view_paths = controller.class.view_paths
      controller.class.view_paths = [ActionView::NullResolver.new()]
      ActionController::Base.allow_forgery_protection = false
    end
    after do
      controller.class.view_paths = @_view_paths
    end
  end

  Rspec.configure do |c|
    c.include self, :example_group => {
      :describes => lambda {|described| described < ActionController::Base }
    }
  end
end
