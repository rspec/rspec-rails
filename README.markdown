# rspec-rails-2

## RSpec-2 for Rails-3

rspec-rails-2 brings rspec-2 to rails-3 with lightweight extensions to both
libraries.

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

    gem "rspec-rails", ">= 2.0.0.beta.8"

This will expose generators, including rspec:install. Now you can run: 

    script/rails g rspec:install

This adds the spec directory and some skeleton files, including
the "rake spec" task.

Note that things are in flux, so some generators generate code that
doesn't work all that well yet.

## Backwards compatibility

This is a complete rewrite of the rspec-rails extension designed to work with
rails-3.x and rspec-2.x. It will not work with older versions of either rspec
or rails.  Many of the APIs from rspec-rails-1 have been carried forward,
however, so upgrading an app from rspec-1/rails-2, while not pain-free, should
not send you to the doctor with a migraine.

## Synopsis

* each example runs in its own transaction
  * configurable in Rspec.configure
    * see generated spec/spec\_helper.rb
* model specs in spec/models
* controller specs in spec/controllers
* view specs in spec/views
* mailer specs in spec/mailers
* observer specs in spec/models
* request specs in spec/requests
  * these wrap rails integration tests
* rails assertions
* assertion-wrapping matchers
  * redirect\_to
  * render\_template
* webrat matchers
* generators
  * run "script/rails g" to see the list of available generators

## Known issues

* no helper specs (yet)
* no routing specs (yet)
* only works with ActiveRecord (for now)

# Controller Specs

Controller specs live in spec/controllers, and mix in
ActionController::TestCase::Behavior. See the documentation
for ActionController::TestCase to see what facilities are
available from Rails.

You can use RSpec expectations/matchers or Test::Unit assertions.

## rendering views
By default, controller specs do not render views (as of beta.9).
This supports specifying controllers without concern for whether
the views they render work correctly or even exist. If you prefer
to render the views (a la Rails' functional tests), you can use the
`render_views` declaration in each example group:

    describe SomeController do
      render_views
      ...

## Matchers
In addition to what Rails offers, controller specs provide all
of rspec-core's matchers and the rspec-rails' specific matchers
as well.

### render_template
Delegates to Rails' assert_template:

    response.should render_template("new")

### redirect_to
Delegates to assert_redirect

    response.should redirect_to(widgets_path)
