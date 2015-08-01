Feature: request spec

  Request specs provide a thin wrapper around Rails' integration tests, and are
  designed to drive behavior through the full stack, including routing
  (provided by Rails) and without stubbing (that's up to you).

  Request specs are marked by `:type => :request` or if you have set
  `config.infer_spec_type_from_file_location!` by placing them in `spec/requests`.

  With request specs, you can:

  * specify a single request
  * specify multiple requests across multiple controllers
  * specify multiple requests across multiple sessions

  Check the rails documentation on integration tests for more information.

  RSpec provides two matchers that delegate to Rails assertions:

      render_template # delegates to assert_template
      redirect_to     # delegates to assert_redirected_to

  Check the Rails docs for details on these methods as well.

  [Capybara](http://github.com/jnicklas/capybara) is no longer supported in
  request specs as of Capybara 2.0.0. The recommended way to use Capybara is
  with [feature specs](../feature-specs/feature-spec).

  Scenario: specify managing a Widget with Rails integration methods
    Given a file named "spec/requests/widget_management_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe "Widget management", :type => :request do

        it "creates a Widget and redirects to the Widget's page" do
          get "/widgets/new"
          expect(response).to render_template(:new)

          post "/widgets", :widget => {:name => "My Widget"}

          expect(response).to redirect_to(assigns(:widget))
          follow_redirect!

          expect(response).to render_template(:show)
          expect(response.body).to include("Widget was successfully created.")
        end

      end
      """
    When I run `rspec spec/requests/widget_management_spec.rb`
    Then the example should pass

  @unsupported-on-rails-3-0
  Scenario: requesting a JSON response
    Given a file named "spec/requests/widget_management_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe "Widget management", :type => :request do

        it "creates a Widget" do
          headers = {
            "ACCEPT" => "application/json",     # This is what Rails 4 accepts
            "HTTP_ACCEPT" => "application/json" # This is what Rails 3 accepts
          }
          post "/widgets", { :widget => {:name => "My Widget"} }, headers

          expect(response.content_type).to eq("application/json")
          expect(response).to have_http_status(:created)
        end

      end
      """
    When I run `rspec spec/requests/widget_management_spec.rb`
    Then the example should pass

  Scenario: providing JSON data
    Given a file named "spec/requests/widget_management_spec.rb" with:
    """ruby
    require "rails_helper"

    RSpec.describe "Widget management", :type => :request do

      it "creates a Widget and redirects to the Widget's page" do
        headers = { "CONTENT_TYPE" => "application/json" }
        post "/widgets", '{ "widget": { "name":"My Widget" } }', headers
        expect(response).to redirect_to(assigns(:widget))
      end

    end
    """
    When I run `rspec spec/requests/widget_management_spec.rb`
    Then the example should pass
