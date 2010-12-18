rspec-rails extends Rails' built-in testing framework to support rspec examples
for requests, controllers, models, views, and helpers.

## Rails-3

rspec-rails-2 supports rails-3.0.0 and later. For earlier versions of Rails,
you need [rspec-rails-1.3](http://rspec.info).

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
      gem "rspec-rails", "~> 2.0.1"
    end

It needs to be in the :development group to expose generators and rake tasks
without having to type RAILS_ENV=test.

Now you can run:

    script/rails generate rspec:install

This adds the spec directory and some skeleton files, including a .rspec
file.

## Generators

If you type script/rails generate, the only RSpec generator you'll actually see
is rspec:install. That's because RSpec is registered with Rails as the test
framework, so whenever you generate application components like models,
controllers, etc, RSpec specs are generated instead of Test::Unit tests.

Note that the generators are there to help you get started, but they are no
substitute for writing your own examples, and they are only guaranteed to work
out of the box for the default scenario (ActiveRecord + Webrat).

## Autotest

The rspec:install generator creates a .rspec file, which tells RSpec to tell
Autotest that you're using RSpec and Rails. You'll also need to add the ZenTest
gem to your Gemfile:

    gem "ZenTest"

At this point, if all of the gems in your Gemfile are installed in system gems,
you can just type autotest. If, however, Bundler is managing any gems for you
directly (i.e. you've got :git or :path attributes in the Gemfile), you'll need
to run bundle exec autotest.

## Webrat and Capybara

You can choose between webrat or capybara for simulating a browser, automating
a browser, or setting expectations using the matchers they supply. Just add
your preference to the Gemfile:

    gem "webrat"
    gem "capybara"

Note that Capybara matchers are not available in view or helper specs.

## Issues

The documentation for rspec-rails is a work in progress. We'll be adding
Cucumber features over time, and clarifying existing ones.  If you have
specific features you'd like to see added, find the existing documentation
incomplete or confusing, or, better yet, wish to write a missing Cucumber
feature yourself, please [submit an
issue](http://github.com/rspec/rspec-rails/issues) or a [pull
request](http://github.com/rspec/rspec-rails).

