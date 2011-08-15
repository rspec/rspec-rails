Feature: Default Rails error handling can be overridden using :bypass_rescue

  Errors from a controller action will normally be handled by the 
  default Rails exception handling mechanism (i.e. they will not 
  propagate out). If handling of particular exceptions
  is implemented outside of the controller under test(e.g. an inherited :rescue_from),
  it may be preferred to assert only that the expected exception was raised.
  This can be accomplished using :bypass_rescue
  
  Background:
    Given a file named "spec/controllers/gadgets_controller_spec_context.rb" with:
    """
    class ErrorHandlingAccessDenied < StandardError; end
    
    class ApplicationController < ActionController::Base
      rescue_from ErrorHandlingAccessDenied, :with => :access_denied

    private

      def access_denied
        redirect_to "/401.html"
      end
    end
    """
  
  Scenario: Standard Rails exception handling (the default)
    Given a file named "spec/controllers/gadgets_controller_spec.rb" with:
        """
        require "spec_helper"

        require 'controllers/gadgets_controller_spec_context'

        describe GadgetsController do
          before do
            def controller.index
              raise ErrorHandlingAccessDenied
            end
          end

          describe "index" do
            it "redirects to the /401.html page" do
              get :index
              response.should redirect_to("/401.html")
            end
          end
        end
        """
    When I run `rspec spec/controllers/gadgets_controller_spec.rb`
    Then the examples should all pass
  
  Scenario: Rails exception rescuing can be bypassed with :bypass_rescue
    Given a file named "spec/controllers/gadgets_controller_spec.rb" with:
        """
        require "spec_helper"

        require 'controllers/gadgets_controller_spec_context'

        describe GadgetsController do
          before do
            def controller.index
              raise ErrorHandlingAccessDenied
            end
          end

          describe "index" do
            it "raises AccessDenied" do
              bypass_rescue
              expect { get :index }.to raise_error(ErrorHandlingAccessDenied)
            end
          end
        end
        """
    When I run `rspec spec/controllers/gadgets_controller_spec.rb`
    Then the examples should all pass
    
