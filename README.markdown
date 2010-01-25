RSpec-2 for Rails-3

### Backwards compatibility

None. This is a rewrite of the rspec-rails extension designed to work
with rails-3.x and rspec-2.x. It will not work with older versions of
either rspec or rails.

### Current state

Currently in super-pre-alpha state - explore at your own risk!

Install:

    git clone git://github.com/rspec/rspec-dev
    cd rspec-dev
    rake git:clone
    rake gem:build
    rake gem:install

This installs the following gems:

* rspec
* rspec-core
* rspec-expectations
* rspec-mocks
* rspec-rails

### What works

Currently supported:

* controller specs in spec/controllers
  * no view isolation yet
* model specs in spec/models
* request specs in spec/requests
  * these wrap rails integration tests
* rails assertions
* webrat matchers
* rails-specific matchers
  * response.should redirect_to(...)
    * wraps assert_redirected_to
    * only works with should (not should_not)
* generators
  * borrowed from José Valim's third_rails repo on github
  * the generators work, but not all the generated specs
    work yet :(

### Known issues

None (or very little) of the following are supported yet (but will be soon):

* rails-specific matchers
  * only supports "response.should redirect_to(..)"
* isolation from views in controller specs
* view specs
* helper specs
* routing specs
