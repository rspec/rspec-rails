# Upgrading from rspec-rails-1.x to rspec-rails-2.

This is a work in progress. Please submit errata, missing steps, or patches to
the [rspec-rails issue tracker](https://github.com/rspec/rspec-rails/issues).

## Rake tasks

Delete lib/tasks/rspec.rake, if present. Rake tasks now live in the rspec-rails
gem.

## `spec_helper.rb`

There were a few changes to the generated `spec/spec_helper.rb` file. We
recommend the following:

1. set aside a copy of your existing `spec/spec_helper.rb` file.
2. run `rails generate spec:install`
3. copy any customizations from your old spec_helper to the new one

If you prefer to make the changes manually in the existing spec_helper, here
is what you need to change:

    # rspec-1
    require 'spec/autorun'

    Spec::Runner.configure do |config|
      ...
    end

    # rspec-2
    require 'rspec/core'

    RSpec.configure do |config|
      ...
    end

## Controller specs

### `response.should render_template`

This needs to move from before the action to after. For example:

    # rspec-rails-1
    controller.should render_template("edit")
    get :edit, :id => "37"

    # rspec-rails-2
    get :edit, :id => "37"
    response.should render_template("edit")

rspec-1 had to monkey patch Rails to get render_template to work before the
action, and this broke a couple of times with Rails releases (requiring urgent
fix releases in RSpec). Part of the philosophy of rspec-rails-2 is to rely on
public APIs in Rails as much as possible. In this case, `render_template`
delegates directly to Rails' `assert_template`, which only works after the
action.
