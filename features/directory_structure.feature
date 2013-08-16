Feature: Directory Structure

  Specs are usually placed in a canonical directory structure that describes
  their purpose.

  * Model specs reside in the `spec/models` directory
  * Controller specs reside in the `spec/controllers` directory
  * Request specs reside in the `spec/requests` directory
  * Feature specs reside in the `spec/features` directory
  * View specs reside in the `spec/views` directory
  * Helper specs reside in the `spec/helpers` directory
  * Mailer specs reside in the `spec/mailers` directory
  * Routing specs reside in the `spec/routing` directory

  If you follow this directory structure, RSpec will automatically include the
  correct test support functions for each type of test.

  Application developers are free to use a different directory structure, but
  will need to specify the types manually by adding a `:type` metadata key (for
  example, `describe WidgetsController, :type => :controller`)

  Scenario: Specs in the `spec/controllers` directory automatically tagged as controller specs
    Given a file named "spec/controllers/widgets_controller_spec.rb" with:
      """ruby
      require "spec_helper"

      describe WidgetsController do
        it "responds successfully" do
          get :index
          expect(response.status).to eq(200)
        end
      end
      """
    When I run `rspec spec`
    Then the example should pass

  Scenario: Specs in other directories must have their types specified manually
    Given a file named "spec/functional/widgets_controller_spec.rb" with:
      """ruby
      require "spec_helper"

      describe WidgetsController, :type => :controller do
        it "responds successfully" do
          get :index
          expect(response.status).to eq(200)
        end
      end
      """
    When I run `rspec spec`
    Then the example should pass

  Scenario: Specs in canonical directories can override their types
    Given a file named "spec/routing/duckduck_routing_spec.rb" with:
      """ruby
      require "spec_helper"

      Rails.application.routes.draw do
        get "/example" => redirect("http://example.com")
      end

      # Due to limitations in the Rails routing test framework, routes that
      # perform redirects must actually be tested via request specs
      describe "/example", :type => :request do
        it "redirects to example.com" do
          get "/example"
          expect(response).to redirect_to("http://example.com")
        end
      end
      """
    When I run `rspec spec`
    Then the example should pass
