# rspec-rails-2

rspec-2 for rails-3 with lightweight extensions to each

NOTICE: rspec-rails-2.0.0.beta.17 only works with rails-3.0.0.beta4 or higher.

## Install

    gem install rspec-rails --pre

This installs the following gems:

* rspec
* rspec-core
* rspec-expectations
* rspec-mocks
* rspec-rails

## Configure:

Add this line to the Gemfile:

    gem "rspec-rails", ">= 2.0.0.beta.17"

This will expose generators, including rspec:install. Now you can run: 

    script/rails g rspec:install

This adds the spec directory and some skeleton files, including
the "rake spec" task.

Note that things are in flux, so some generators generate code that
doesn't work all that well yet.

## Living on edge

If you prefer to exploit bundler's support for pointing a gem at a github repo,
be sure to do so for all five of the relevant rspec gems:

    gem "rspec-rails",        :git => "git://github.com/rspec/rspec-rails.git"
    gem "rspec",              :git => "git://github.com/rspec/rspec.git"
    gem "rspec-core",         :git => "git://github.com/rspec/rspec-core.git"
    gem "rspec-expectations", :git => "git://github.com/rspec/rspec-expectations.git"
    gem "rspec-mocks",        :git => "git://github.com/rspec/rspec-mocks.git"

Keep in mind that each of these repos is under active development, which means
that its very likely that you'll pull from these repos and they won't play nice
together. If playing nice is important to you, stick to the published gems.

## Backwards compatibility

This is a complete rewrite of the rspec-rails extension designed to work with
rails-3.x and rspec-2.x. It will not work with older versions of either rspec
or rails.  Many of the APIs from rspec-rails-1 have been carried forward,
however, so upgrading an app from rspec-1/rails-2, while not pain-free, should
not send you to the doctor with a migraine.

## Known issues

See http://github.com/rspec/rspec-rails/issues

# Request Specs

Request specs live in spec/requests.

    describe "widgets resource" do
      describe "GET index" do
        it "contains the widgets header" do
          get "/widgets/index"
          response.should have_selector("h1", :content => "Widgets")
        end
      end
    end

Request specs mix in behavior from Rails' integration tests. See the
docs for ActionDispatch::Integration::Runner for more information.

# Controller Specs

Controller specs live in spec/controllers, and mix in
ActionController::TestCase::Behavior. See the documentation
for ActionController::TestCase to see what facilities are
available from Rails.

You can use RSpec expectations/matchers or Test::Unit assertions.

## `render_views`
By default, controller specs do not render views.  This supports specifying
controllers without concern for whether the views they render work correctly
(NOTE: the template must exist, unlike rspec-rails-1. See Upgrade.markdown for
more information about this). If you prefer to render the views (a la Rails'
functional tests), you can use the `render_views` declaration in each example
group:

    describe SomeController do
      render_views
      ...

### * Upgrade note

`render_views` replaces `integrate_views` from rspec-rails-1.3

## `assigns`

Use `assigns(key)` to express expectations about instance variables that a controller
assigns to the view in the course of an action:

    get :index
    assigns(:widgets).should eq(expected_value)

# View specs

View specs live in spec/views, and mix in ActionView::TestCase::Behavior.

    describe "events/index.html.erb" do
      it "renders _event partial for each event" do
        assign(:events, [stub_model(Event), stub_model(Event)])
        render
        view.should render_template(:partial => "_event", :count => 2)
      end
    end

    describe "events/show.html.erb" do
      it "displays the event location" do
        assign(:event, stub_model(Event,
          :location => "Chicago"
        )
        render
        rendered.should contain("Chicago")
      end
    end
    
## `assign(key, val)`

Use this to assign values to instance variables in the view:

    assign(:widget, stub_model(Widget))
    render
    
The code above assigns `stub_model(Widget)` to the `@widget` variable in the view, and then
renders the view.

### * Upgrade note

`assign(key, value)` replaces `assigns[key] = value` from rspec-rails-1.3

## `rendered`

This represents the rendered view.

    render
    rendered.should =~ /Some text expected to appear on the page/

### * Upgrade note

`rendered` replaces `response` from rspec-rails-1.3

# Routing specs

Routing specs live in spec/routing.

    describe "routing to profiles" do
      it "routes /profile/:username to profile#show for username" do
        { :get => "/profiles/jsmith" }.should route_to(
          :controller => "profiles",
          :action => "show",
          :username => "jsmith"
        )
      end

      it "does not expose a list of profiles" do
        { :get => "/profiles" }.should_not be_routable
      end
    end

# Helper specs

Helper specs live in spec/helpers, and mix in ActionView::TestCase::Behavior.

    describe EventsHelper do
      describe "#link_to_event" do
        it "displays the title, and formatted date" do
          event = Event.new("Ruby Kaigi", Date.new(2010, 8, 27))
          # helper is an instance of ActionView::Base configured with the
          # EventsHelper and all of Rails' built-in helpers
          helper.link_to_event.should =~ /Ruby Kaigi, 27 Aug, 2010/
        end
      end
    end

# Matchers

rspec-rails exposes domain-specific matchers to each of the example group types. Most
of them simply delegate to Rails' assertions.

## `be_a_new`
* Available in all specs.
* Primarily intended for controller specs

<pre>
object.should be_a_new(Widget)
</pre>

Passes if the object is a `Widget` and returns true for `new_record?`

## `render_template`
* Delegates to Rails' assert_template.
* Available in request, controller, and view specs.

In request and controller specs, apply to the response object:

    response.should render_template("new")

In view specs, apply to the view object:

    view.should render_template(:partial => "_form", :locals => { :widget => widget } )

## `redirect_to`
* Delegates to assert_redirect
* Available in request and controller specs.

<pre>
response.should redirect_to(widgets_path)
</pre>

## `route_to`

* Delegates to Rails' assert_routing.
* Available in routing and controller specs.

<pre>
{ :get => "/widgets" }.should route_to(:controller => "widgets", :action => "index")
</pre>

## `be_routable`

Passes if the path is recognized by Rails' routing. This is primarily intended
to be used with `should_not` to specify routes that should not be routable.

    { :get => "/widgets/1/edit" }.should_not be_routable

## Contribute

See [http://github.com/rspec/rspec-dev](http://github.com/rspec/rspec-dev)

## Also see

* [http://github.com/rspec/rspec](http://github.com/rspec/rspec)
* [http://github.com/rspec/rspec-core](http://github.com/rspec/rspec-core)
* [http://github.com/rspec/rspec-expectations](http://github.com/rspec/rspec-expectations)
* [http://github.com/rspec/rspec-mocks](http://github.com/rspec/rspec-mocks)
