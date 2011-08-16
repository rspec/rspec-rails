Feature: anonymous controller

  Use the `controller` method to define an anonymous controller derived from
  ApplicationController, or any other base controller. This is useful for
  specifying behavior like global error handling.

  Scenario: specify error handling in ApplicationController
    Given a file named "spec/controllers/application_controller_spec.rb" with:
    """
    require "spec_helper"

    class ApplicationController < ActionController::Base
      class AccessDenied < StandardError; end

      rescue_from AccessDenied, :with => :access_denied

    private

      def access_denied
        redirect_to "/401.html"
      end
    end

    describe ApplicationController do
      controller do
        def index
          raise ApplicationController::AccessDenied
        end
      end

      describe "handling AccessDenied exceptions" do
        it "redirects to the /401.html page" do
          get :index
          response.should redirect_to("/401.html")
        end
      end
    end
    """
    When I run `rspec spec`
    Then the examples should all pass

  Scenario: specify error handling in subclass of ApplicationController
    Given a file named "spec/controllers/application_controller_subclass_spec.rb" with:
    """
    require "spec_helper"

    class ApplicationController < ActionController::Base
      class AccessDenied < StandardError; end
    end

    class ApplicationControllerSubclass < ApplicationController

      rescue_from ApplicationController::AccessDenied, :with => :access_denied

      private

      def access_denied
        redirect_to "/401.html"
      end
    end

    describe ApplicationControllerSubclass do
      controller(ApplicationControllerSubclass) do
        def index
          raise ApplicationController::AccessDenied
        end
      end

      describe "handling AccessDenied exceptions" do
        it "redirects to the /401.html page" do
          get :index
          response.should redirect_to("/401.html")
        end
      end
    end
    """
    When I run `rspec spec`
    Then the examples should all pass

  Scenario: base class can be inferred
    Given a file named "spec/support/base_class_is_inferred_config.rb" with:
    """
    require "spec_helper"

    RSpec.configure do |c|
      c.infer_base_class_for_anonymous_controllers = true
    end
    """
    And a file named "spec/controllers/base_class_can_be_inferred_spec.rb" with:
    """
    require "spec_helper"

    class ApplicationController < ActionController::Base
    end

    class ApplicationControllerSubclass < ApplicationController
    end

    describe ApplicationControllerSubclass do
      controller do
        def index
          render :text => "Hello World"
        end
      end

      it "creates an anonymous controller that inherits from ApplicationControllerSubclass" do
        controller.should be_a_kind_of(ApplicationControllerSubclass)
      end
    end
    """
    When I run `rspec spec`
    Then the examples should all pass

  Scenario: regression with ApplicationController around_filters
    Given a file named "spec/controllers/application_controller_around_filter_spec.rb" with:
    """
    require "spec_helper"

    class ApplicationController < ActionController::Base
      around_filter :some_around_filter

      def some_around_filter
        @callback_invoked = true
        yield
      end
    end

    describe ApplicationController do
      controller do
        def index
          render :nothing => true
        end
      end

      it "invokes the callback" do
        get :index

        assigns[:callback_invoked].should be_true
      end
    end
    """
    When I run `rspec spec`
    Then the examples should all pass
