Controller specs live in `spec/controllers` or any example group with
`:type => :controller`.

A controller spec is an RSpec wrapper for a Rails functional test
([ActionController::TestCase::Behavior](https://github.com/rails/rails/blob/master/actionpack/lib/action_controller/test_case.rb)).
It allows you to simulate a single http request in each example, and then
specify expected outcomes such as:

* rendered templates
* redirects
* instance variables assigned in the controller to be shared with the view
* cookies sent back with the response

To specify outcomes, you can use:

* standard rspec matchers (`expect(response.status).to eq(200)`)
* standard test/unit assertions (`assert_equal 200, response.status`)
* rails assertions (`assert_response 200`)
* rails-specific matchers:
  * `expect(response).to render_template(wraps assert_template)`
  * `expect(response).to redirect_to(wraps assert_redirected_to)`
  * `expect(assigns(:widget)).to be_a_new(Widget)`

## Examples

    describe TeamsController do
      describe "GET index" do
        it "assigns @teams" do
          team = Team.create
          get :index
          expect(assigns(:teams)).to eq([team])
        end

        it "renders the index template" do
          get :index
          expect(response).to render_template("index")
        end
      end
    end

## Views

* by default, views are not rendered. See
  [views are stubbed by default](controller-specs/views-are-stubbed-by-default) and
  [render_views](controller-specs/render-views) for details.
