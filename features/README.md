rspec-rails extends Rails' built-in testing framework to support rspec
examples for requests, controllers, models, views, helpers, mailers and
routing.

## Rails

rspec-rails 5 supports Rails 5.2 to 6.1. For earlier versions of Rails, you
should use [rspec-rails-4](https://github.com/rspec/rspec-rails/tree/4-1-maintenance)
for Rails 5.x and [rspec-rails 3](https://github.com/rspec/rspec-rails/tree/3-9-maintenance)
for even older versions.

## Install

    gem install rspec-rails

This installs the following gems:

    rspec
    rspec-core
    rspec-expectations
    rspec-mocks
    rspec-rails

## Configure

Add rspec-rails to the :test and :development groups in the Gemfile:

    group :test, :development do
      gem 'rspec-rails', '~> 5.0.0'
    end

It needs to be in the :development group to expose generators and rake tasks
without having to type RAILS_ENV=test.

Now you can run:

    bundle exec rails generate rspec:install

This adds the spec directory and some skeleton files, including a .rspec
file.

You can also customize the default spec path with `--default-path` option:

    bundle exec rails generate rspec:install --default-path behaviour

## Issues

The documentation for rspec-rails is a work in progress. We'll be adding
Cucumber features over time, and clarifying existing ones.  If you have
specific features you'd like to see added, find the existing documentation
incomplete or confusing, or, better yet, wish to write a missing Cucumber
feature yourself, please [submit an
issue](https://github.com/rspec/rspec-rails/issues) or a [pull
request](https://github.com/rspec/rspec-rails).
