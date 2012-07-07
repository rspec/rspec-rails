RSpec.configure do |config|
  config.add_setting :infer_base_class_for_anonymous_controllers, :default => false
end

module RSpec::Rails
  module ControllerExampleGroup
    extend ActiveSupport::Concern
    include RSpec::Rails::RailsExampleGroup
    include ActionController::TestCase::Behavior
    include RSpec::Rails::ViewRendering
    include RSpec::Rails::Matchers::RedirectTo
    include RSpec::Rails::Matchers::RenderTemplate
    include RSpec::Rails::Matchers::RoutingMatchers

    module ClassMethods
      # @private
      def controller_class
        described_class
      end

      # Supports a simple DSL for specifying behavior of ApplicationController.
      # Creates an anonymous subclass of ApplicationController and evals the
      # `body` in that context. Also sets up implicit routes for this
      # controller, that are separate from those defined in "config/routes.rb".
      #
      # @note Due to Ruby 1.8 scoping rules in anoymous subclasses, constants
      #   defined in `ApplicationController` must be fully qualified (e.g.
      #   `ApplicationController::AccessDenied`) in the block passed to the
      #   `controller` method. Any instance methods, filters, etc, that are
      #   defined in `ApplicationController`, however, are accessible from
      #   within the block.
      #
      # @example
      #
      #     describe ApplicationController do
      #       controller do
      #         def index
      #           raise ApplicationController::AccessDenied
      #         end
      #       end
      #
      #       describe "handling AccessDenied exceptions" do
      #         it "redirects to the /401.html page" do
      #           get :index
      #           response.should redirect_to("/401.html")
      #         end
      #       end
      #     end
      #
      # If you would like to spec a subclass of ApplicationController, call
      # controller like so:
      #
      #     controller(ApplicationControllerSubclass) do
      #       # ....
      #     end
      def controller(base_class = nil, &body)
        base_class ||= RSpec.configuration.infer_base_class_for_anonymous_controllers? ?
                         controller_class :
                         ApplicationController

        metadata[:example_group][:described_class] = Class.new(base_class) do
          def self.name; "AnonymousController"; end
        end
        metadata[:example_group][:described_class].class_eval(&body)

        before do
          @orig_routes, @routes = @routes, ActionDispatch::Routing::RouteSet.new
          @routes.draw { resources :anonymous }
        end

        after do
          @routes, @orig_routes = @orig_routes, nil
        end
      end
    end

    attr_reader :controller, :routes

    module BypassRescue
      def rescue_with_handler(exception)
        raise exception
      end
    end

    # Extends the controller with a module that overrides
    # `rescue_with_handler` to raise the exception passed to it.  Use this to
    # specify that an action _should_ raise an exception given appropriate
    # conditions.
    #
    # @example
    #
    #     describe ProfilesController do
    #       it "raises a 403 when a non-admin user tries to view another user's profile" do
    #         profile = create_profile
    #         login_as profile.user
    #
    #         expect do
    #           bypass_rescue
    #           get :show, :id => profile.id + 1
    #         end.to raise_error(/403 Forbidden/)
    #       end
    #     end
    def bypass_rescue
      controller.extend(BypassRescue)
    end

    # If method is a named_route, delegates to the RouteSet associated with
    # this controller.
    def method_missing(method, *args, &block)
      if @orig_routes && @orig_routes.named_routes.helpers.include?(method)
        controller.send(method, *args, &block)
      else
        super
      end
    end

    included do
      subject { controller }

      metadata[:type] = :controller

      before do
        @routes = ::Rails.application.routes
        ActionController::Base.allow_forgery_protection = false
      end
    end
  end
end
