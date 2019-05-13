Feature: Cookies

  There is different ways to test cookies in controller's tests be we recommend
  to use `cookies` as below.

  You can use strings or symbols to fetch or set your cookies because `cookies`
  support indifferent access.

  Scenario: Testing cookie's value cleared in controller
    Given a file named "spec/controllers/application_controller_spec.rb" with:
      """ruby
      require "rails_helper"

      RSpec.describe ApplicationController, :type => :controller do
        controller do
          def clear_cookie
            cookies.delete(:user_name)
            head :ok
          end
        end

        before do
          routes.draw { get "clear_cookie" => "anonymous#clear_cookie" }
        end

        it "clear cookie's value 'user_name'" do
          cookies[:user_name] = "Sam"

          get :clear_cookie

          expect(cookies[:user_name]).to eq nil
        end
      end
      """
    When I run `rspec spec`
    Then the example should pass
