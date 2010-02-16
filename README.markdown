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

    gem "rspec-rails", ">= 2.0.0.a7"

This will expose generators, including rspec:install. Once you run that:

    script/rails g rspec:install

... you'll have the spec task added to your rake tasks.

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
* request specs in spec/requests
  * these wrap rails integration tests
* rails assertions
* assertion-wrapping matchers
  * redirect_to
  * render_template
    * template must exist (unlike rspec-rails-1.x)
* webrat matchers
* generators

### Known issues

* no view specs
* no helper specs
* no routing specs
* only works with ActiveRecord

