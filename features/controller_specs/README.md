A controller spec is an RSpec wrapper for a Rails functional test. It allows
you to simulate a single http request in each example, and then specify
expected outcomes, such as:

* templates that are rendered by the action
* instance variables that are assigned in the controller to be shared with
  the view
* cookies that get sent back with the response

To specify outcomes, you can use:
    
* standard rspec matchers (response.code.should eq(200))
* standard test/unit assertions (assert_equal 200, response.code)
* rails assertions (assert_response 200)
* rails-specific matchers:
  * response.should render_template (wraps assert_template)
  * response.should redirect_to (wraps assert_redirected_to)
  * assigns(:widget).should be_a_new(Widget)
    
Conventions:

* pass the controller being spec'd to the describe method
  * this is only necessary for the outermost example group
* by default, views are not rendered. See "isolation from views" and
  "render_views" for details
