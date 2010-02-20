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
* view specs in spec/views
* request specs in spec/requests
  * these wrap rails integration tests
* rails assertions
* assertion-wrapping matchers
  * redirect_to
  * render_template
    * template must exist (unlike rspec-rails-1.x)
* webrat matchers
* generators

### Rails 3 generators

To see list of available generators, run this from your rails app root directory

  rails g 
  
The RSpec generators are available under the RSpec namespace

* rspec:controller [name] [actions]
* rspec:helper
  * generates spec_helper file
* rspec:install 
  * generates skeleton file structure for using rspec with rails 3 app
* rspec:integration [name]
* rspec:mailer [name]
* rspec:model [name] [attributes]
* rspec:observer [name]
* rspec:plugin
* rspec:scaffold [name] [attributes]
* rspec:view [name]

### Known issues

* no helper specs
* no routing specs
* only works with ActiveRecord

