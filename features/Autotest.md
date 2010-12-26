The rspec:install generator creates a .rspec file, which tells RSpec to tell
Autotest that you're using RSpec and Rails. You'll also need to add the ZenTest
gem to your Gemfile:

    gem "ZenTest"

At this point, if all of the gems in your Gemfile are installed in system gems,
you can just type autotest. If, however, Bundler is managing any gems for you
directly (i.e. you've got :git or :path attributes in the Gemfile), you'll need
to run bundle exec autotest.
