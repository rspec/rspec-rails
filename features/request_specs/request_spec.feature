Feature: request spec

  Request specs allow you to spec the interaction of your
  Rails application across multiple controllers. This is generally
  known as "full stack" testing.
  
  RSpec provides two matchers that delegate to Rails assertion methods:
  
  `render_template` (delegated to `assert_template`)
  `redirect_to` (delegated to `assert_redirected_to`)
  
  Please check the Rails documentation for options on these methods.
  
  Also, if you would like to use webrat or capybara with your request
  specs, all you have to do is include one of them in your Gemfile and
  RSpec will automatically load them.
  
  Scenario: specify managing a Widget with Rails integration methods
    Given a file named "spec/requests/widget_management_spec.rb" with:
      """
      require "spec_helper"

      describe "Widget management" do
        
        it "creates a Widget and redirects to the Widget's page" do
          get "/widgets/new"
          response.should render_template(:new)
          
          post "/widgets", :widget => {:name => "My Widget"}
          
          response.should redirect_to(assigns(:widget))
          follow_redirect!
          
          response.should render_template(:show)
          response.body.should include("Widget was successfully created.")
        end
      
      end
      """
    When I run `rspec spec/requests/widget_management_spec.rb`
    Then the example should pass