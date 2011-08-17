Feature: anonymous controller

  Use the `controller` method to define an anonymous controller derived from
  `ApplicationController`. This is useful for specifying behavior like global
  error handling.

  To specify a different base class, you can pass the class explicitly to the
  controller method:

      controller(BaseController)

  You can also configure RSpec to use the described class:

      RSpec.configure do |c|
        c.infer_base_class_for_anonymous_controllers = true
      end

      describe BaseController do
        controller { ... }
        # ^^ creates an anonymous subclass of `BaseController`

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

  Scenario: infer base class from the described class
    Given a file named "spec/controllers/base_class_can_be_inferred_spec.rb" with:
      """
      require "spec_helper"

      RSpec.configure do |c|
        c.infer_base_class_for_anonymous_controllers = true
      end

      class ApplicationController < ActionController::Base; end

      class ApplicationControllerSubclass < ApplicationController; end

      describe ApplicationControllerSubclass do
        controller do
          def index
            render :text => "Hello World"
          end
        end

        it "creates an anonymous controller derived from ApplicationControllerSubclass" do
          controller.should be_a_kind_of(ApplicationControllerSubclass)
        end
      end
      """
    When I run `rspec spec`
    Then the examples should all pass

  Scenario: invoke around filter in base class
    Given a file named "spec/controllers/application_controller_around_filter_spec.rb" with:
      """
      require "spec_helper"

      class ApplicationController < ActionController::Base
        around_filter :an_around_filter

        def an_around_filter
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
