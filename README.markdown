RSpec-2 for Rails-3

### Backwards compatibility

None. This is a rewrite of the rspec-rails extension designed to work
with rails-3.x and rspec-2.x. It will not work with older versions of
either rspec or rails.

### Current state

Currently in super-pre-alpha state - explore at your own risk!

Install:

    gem install rspec-rails --pre

Build from source and install:

    git clone git://github.com/rspec/rspec-dev
    cd rspec-dev
    rake

This installs the following gems:

* rspec
* rspec-core
* rspec-expectations
* rspec-mocks
* rspec-rails

### What works

Currently supported:

* each example runs in its own transaction
  * not yet configurable
    * i.e. no way to turn this off
* model specs in spec/models
* controller specs in spec/controllers
* request specs in spec/requests
  * these wrap rails integration tests
* rails assertions
* webrat matchers
* generators

### Known issues

* no view specs
* no helper specs
* no routing specs

