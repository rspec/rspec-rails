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
      """ruby
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
            expect(response).to redirect_to("/401.html")
          end
        end
      end
      """
    When I run `rspec spec`
    Then the examples should all pass

  Scenario: specify error handling in subclass of ApplicationController
    Given a file named "spec/controllers/application_controller_subclass_spec.rb" with:
      """ruby
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
            expect(response).to redirect_to("/401.html")
          end
        end
      end
      """
    When I run `rspec spec`
    Then the examples should all pass

  Scenario: infer base class from the described class
    Given a file named "spec/controllers/base_class_can_be_inferred_spec.rb" with:
      """ruby
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
          expect(controller).to be_a_kind_of(ApplicationControllerSubclass)
        end
      end
      """
    When I run `rspec spec`
    Then the examples should all pass

  Scenario: invoke around filter in base class
    Given a file named "spec/controllers/application_controller_around_filter_spec.rb" with:
      """ruby
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

          expect(assigns[:callback_invoked]).to be_true
        end
      end
      """
    When I run `rspec spec`
    Then the examples should all pass

  Scenario: anonymous controllers only create resource routes
    Given a file named "spec/controllers/application_controller_spec.rb" with:
    """ruby
    require "spec_helper"

    describe ApplicationController do
      controller do
        def index
          render :text => "index called"
        end

        def create
          render :text => "create called"
        end

        def new
          render :text => "new called"
        end

        def show
          render :text => "show called"
        end

        def edit
          render :text => "edit called"
        end

        def update
          render :text => "update called"
        end

        def destroy
          render :text => "destroy called"
        end

        def willerror
          render :text => "will not render"
        end
      end

      describe "#index" do
        it "responds to GET" do
          get :index
          expect(response.body).to eq "index called"
        end

        it "also responds to POST" do
          post :index
          expect(response.body).to eq "index called"
        end

        it "also responds to PUT" do
          put :index
          expect(response.body).to eq "index called"
        end

        it "also responds to DELETE" do
          delete :index
          expect(response.body).to eq "index called"
        end
      end

      describe "#create" do
        it "responds to POST" do
          post :create
          expect(response.body).to eq "create called"
        end

        # And the rest...
        %w{get post put delete}.each do |calltype|
          it "responds to #{calltype}" do
            send(calltype, :create)
            expect(response.body).to eq "create called"
          end
        end
      end

      describe "#new" do
        it "responds to GET" do
          get :new
          expect(response.body).to eq "new called"
        end

        # And the rest...
        %w{get post put delete}.each do |calltype|
          it "responds to #{calltype}" do
            send(calltype, :new)
            expect(response.body).to eq "new called"
          end
        end
      end

      describe "#edit" do
        it "responds to GET" do
          get :edit, :id => "anyid"
          expect(response.body).to eq "edit called"
        end

        it "requires the :id parameter" do
          expect { get :edit }.to raise_error(ActionController::RoutingError)
        end

        # And the rest...
        %w{get post put delete}.each do |calltype|
          it "responds to #{calltype}" do
            send(calltype, :edit, {:id => "anyid"})
            expect(response.body).to eq "edit called"
          end
        end
      end

      describe "#show" do
        it "responds to GET" do
          get :show, :id => "anyid"
          expect(response.body).to eq "show called"
        end

        it "requires the :id parameter" do
          expect { get :show }.to raise_error(ActionController::RoutingError)
        end

        # And the rest...
        %w{get post put delete}.each do |calltype|
          it "responds to #{calltype}" do
            send(calltype, :show, {:id => "anyid"})
            expect(response.body).to eq "show called"
          end
        end
      end

      describe "#update" do
        it "responds to PUT" do
          put :update, :id => "anyid"
          expect(response.body).to eq "update called"
        end

        it "requires the :id parameter" do
          expect { put :update }.to raise_error(ActionController::RoutingError)
        end

        # And the rest...
        %w{get post put delete}.each do |calltype|
          it "responds to #{calltype}" do
            send(calltype, :update, {:id => "anyid"})
            expect(response.body).to eq "update called"
          end
        end
      end

      describe "#destroy" do
        it "responds to DELETE" do
          delete :destroy, :id => "anyid"
          expect(response.body).to eq "destroy called"
        end

        it "requires the :id parameter" do
          expect { delete :destroy }.to raise_error(ActionController::RoutingError)
        end

        # And the rest...
        %w{get post put delete}.each do |calltype|
          it "responds to #{calltype}" do
            send(calltype, :destroy, {:id => "anyid"})
            expect(response.body).to eq "destroy called"
          end
        end
      end

      describe "#willerror" do
        it "cannot be called" do
          expect { get :willerror }.to raise_error(ActionController::RoutingError)
        end
      end
    end
    """
    When I run `rspec spec`
    Then the examples should all pass

  Scenario: draw custom routes for anonymous controllers
    Given a file named "spec/controllers/application_controller_spec.rb" with:
    """ruby
    require "spec_helper"

    describe ApplicationController do
      controller do
        def custom
          render :text => "custom called"
        end
      end

      specify "a custom action can be requested if routes are drawn manually" do
        routes.draw { get "custom" => "anonymous#custom" }

        get :custom
        expect(response.body).to eq "custom called"
      end
    end
    """
    When I run `rspec spec`
    Then the examples should all pass
