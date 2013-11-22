rspec-rails extends Rails' built-in testing framework to support rspec
examples for requests, controllers, models, views, helpers, mailers and
routing.

## Rails

rspec-rails 3 supports Rails 3.x and 4.x. For earlier versions of Rails, you
need [rspec-rails 1](https://github.com/dchelimsky/rspec-rails).

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
      gem 'rspec-rails', '~> 3.0.0.beta'
    end

It needs to be in the :development group to expose generators and rake tasks
without having to type RAILS_ENV=test.

Now you can run:

    script/rails generate rspec:install

This adds the spec directory and some skeleton files, including a .rspec
file.

## Issues

The documentation for rspec-rails is a work in progress. We'll be adding
Cucumber features over time, and clarifying existing ones.  If you have
specific features you'd like to see added, find the existing documentation
incomplete or confusing, or, better yet, wish to write a missing Cucumber
feature yourself, please [submit an
issue](http://github.com/rspec/rspec-rails/issues) or a [pull
request](http://github.com/rspec/rspec-rails).
