RSpec-2 for Rails-3

### Backwards compatibility

None. This is a rewrite of the rspec-rails extension designed to work
with rails-3.x and rspec-2.x. It will not work with older versions of
either rspec or rails.

### Current state

Currently in super-pre-alpha state - explore at your own risk!

Here's what works right now:

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

### Known issues

None of the following are supported yet (but will be soon):

* rails-specific matchers
* isolation from views in controller specs
* view specs of any kind
* helper specs of any kind




