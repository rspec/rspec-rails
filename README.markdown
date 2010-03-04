RSpec-2 for Rails-3

### Backwards compatibility

None. This is a rewrite of the rspec-rails extension designed to work
with rails-3.x and rspec-2.x. It will not work with older versions of
either rspec or rails.

### Current state

Currently in alpha - some things work, some not so much - see Known Issues,
below

Install:

    gem install rspec-rails --pre

This installs the following gems:

* rspec
* rspec-core
* rspec-expectations
* rspec-mocks
* rspec-rails

Configure:

Add this line to the Gemfile:

    gem "rspec-rails", ">= 2.0.0.beta.1"

This will expose generators, including rspec:install. Now you can run: 

    script/rails g rspec:install

This adds the spec directory and some skeleton files, including
the "rake spec" task.

Note that things are in flux, so some generators generate code that
doesn't work all that well yet.

### What works (and what doesn't)

Currently supported:

* each example runs in its own transaction
  * not yet configurable
    * i.e. no way to turn this off
* model specs in spec/models
* controller specs in spec/controllers
  * no view isolation yet
* view specs in spec/views
* mailer specs in spec/mailers
* observer specs in spec/models
* request specs in spec/requests
  * these wrap rails integration tests
* rails assertions
* assertion-wrapping matchers
  * redirect_to
  * render_template
    * template must exist (unlike rspec-rails-1.x)
* webrat matchers
* generators
  * run "script/rails g" to see the list of available generators

### Known issues

* no helper specs
* no routing specs
* only works with ActiveRecord

## Controller Specs

Controller specs live in spec/controllers, and include
behavior from ActionDispatch::Integration::Runner. The
format for a request is:

    # get action, params, headers
    get :show, {:id => '37'}, {'HTTP_ACCEPT' => Mime::JS}

This works for `get`, `post`, `put`, `delete`, `head`.

After a request is made, you set expectations on the `request` and `response`
objects.
