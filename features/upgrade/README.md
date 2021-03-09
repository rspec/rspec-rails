# Upgrading from rspec-rails 4.x to version 5

RSpec Rails 5 is a major version under semantic versioning, it also follows our new versioning strategy for RSpec-Rails, which is to keep in step with Rails supported versions. Thus it supports 5.2, 6.0 and 6.1. There are no changes required to upgrade to RSpec Rails 5 if you are using a supported version of Rails.

If you are using an older version of Rails, you can use 4.x which hard supports 5.0 and 5.1, and soft supports 4.2 (which is unmaintained).

# Upgrading from rspec-rails 3.x to version 4

RSpec Rails 4 is a major version under semantic versioning, it allowed us to change the supported Rails versions to 5 and 6 only. There are no changes required to upgrade to RSpec Rails 4 if you are using Rails 5 or 6.

If you are using Rails 4.2 you can use RSpec Rails 4, but note that support for it is not maintained, we consider this a breaking change hence the version change, and you must be on Ruby 2.2 as a minimum.

If you are upgrading from an earlier version of RSpec Rails, please consult [the upgrading 2.x to 3.x guide](https://relishapp.com/rspec/rspec-rails/v/3-9/docs/upgrade).
