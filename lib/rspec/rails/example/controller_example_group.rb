module RSpec::Rails
  # Extends ActionController::TestCase::Behavior to work with RSpec.
  #
  # == Examples
  #
  # == with stubs
  #
  #   describe WidgetsController do
  #     describe "GET index" do
  #       it "assigns all widgets to @widgets" do
  #         widget = stub_model(Widget)
  #         Widget.stub(:all) { widget }
  #         get :index
  #         assigns(:widgets).should eq([widget])
  #       end
  #     end
  #   end
  #
  # === with a factory
  #
  #   describe WidgetsController do
  #     describe "GET index" do
  #       it "assigns all widgets to @widgets" do
  #         widget = Factory(:widget)
  #         get :index
  #         assigns(:widgets).should eq([widget])
  #       end
  #     end
  #   end
  #
  # === with fixtures
  #
  #   describe WidgetsController do
  #     describe "GET index" do
  #       fixtures :widgets
  #
  #       it "assigns all widgets to @widgets" do
  #         get :index
  #         assigns(:widgets).should eq(Widget.all)
  #       end
  #     end
  #   end
  #
  # == Matchers
  #
  # In addition to the stock matchers from rspec-expectations, controller
  # specs add these matchers, which delegate to rails' assertions:
  #
  #   response.should render_template(*args)
  #   => delegates to assert_template(*args)
  #
  #   response.should redirect_to(destination)
  #   => delegates to assert_redirected_to(destination)
  #
  # == Isolation from views
  #
  # RSpec's preferred approach to spec'ing controller behaviour is to isolate
  # the controller from its collaborators.  By default, therefore, controller
  # example groups do not render views. This means that a view template need
  # not even exist in order to run a controller spec, and you can still specify
  # which template the controller should render.
  #
  # == View rendering
  #
  # If you prefer a more integrated approach, similar to that of
  # Rails' functional tests, you can tell controller groups to
  # render views with the +render_views+ declaration:
  #
  #   describe WidgetsController do
  #     render_views
  #     ...
  #
  module ControllerExampleGroup
    extend ActiveSupport::Concern
    extend RSpec::Rails::ModuleInclusion

    include RSpec::Rails::SetupAndTeardownAdapter
    include RSpec::Rails::TestUnitAssertionAdapter
    include ActionController::TestCase::Behavior
    include RSpec::Rails::ViewRendering
    include Webrat::Methods
    include Webrat::Matchers
    include RSpec::Matchers
    include RSpec::Rails::Matchers::RedirectTo
    include RSpec::Rails::Matchers::RenderTemplate
    include RSpec::Rails::Matchers::RoutingMatchers

    module ClassMethods
      def controller_class
        describes
      end
    end

    module InstanceMethods
      attr_reader :controller, :routes
    end

    included do
      metadata[:type] = :controller
      before do
        @routes = ::Rails.application.routes
        ActionController::Base.allow_forgery_protection = false
      end
    end

    RSpec.configure &include_self_when_dir_matches('spec','controllers')
  end
end
