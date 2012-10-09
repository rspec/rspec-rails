## Set up the dev environment

    git clone git://github.com/rspec/rspec-rails.git
    cd rspec-rails
    gem install bundler
    bundle install --binstubs

Now you should be able to run any of:

    bin/rake
    bin/rake spec
    bin/rake cucumber

## Rails version

rspec-rails runs its tests against many versions of Rails. To switch the
active version used for tests, use the `thor version:use` command.

Examples:

    thor version:use 3.2.8
    thor version:use 3-2-stable
    thor version:use master

## Customize the dev enviroment

The Gemfile includes the gems you'll need to be able to run specs. If you want
to customize your dev enviroment with additional tools like guard or
ruby-debug, add any additional gem declarations to Gemfile-custom (see
Gemfile-custom.sample for some examples).
