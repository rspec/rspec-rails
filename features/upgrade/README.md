# Upgrading

RSpec Rails versions follow semantic versioning of x.y.z where:

- `x` is a major release containing breaking changes and support changes for Rails.
- `y` is a minor release which will contain only feature additions and bug fixes.
- `z` is a patch release which will contain only bug fixes for the minor levels currently supported version of Rails.

On new Rails minor releases we will usually release our own new minor version to support that version, occasionally
we will release a new major version instead to allow us to remove support for now unsupported versions of Rails
as defined by the Rails team themselves.

The RSpec team will only maintain the current major / minor version, although it is common for the `main` branch
to contain changes for the next upcoming version of Rails and usage of this branch directly is also supported.

# Upgrading from rspec-rails 6.x to version 7

RSpec Rails 7 supports Rails versions 7.0, 7.1 and 7.2. There are no changes required to upgrade from 6.x to 7 for these versions of Rails,
but we encourage those doing multiple step upgrades to upgrade to Rails 7.1 and RSpec Rails 6.1.x before upgrading to Rails 7.2 and RSpec Rails 7.0.

If you are on Rails 6.1 you will need to keep using RSpec Rails 6.1.

# Upgrading from rspec-rails 5.x to version 6

RSpec Rails 6 supports Rails versions 6.1, 7.0 and 7.1. There are no changes required to upgrade from 5.x to 6 for these versions of Rails.

# Upgrading from rspec-rails 4.x to version 5

RSpec Rails 5 supports 5.2, 6.0 and 6.1. There are no changes required to upgrade from 4.x to 5 for these versions of Rails.

If you are using an older version of Rails, you can use 4.x which hard supports 5.0 and 5.1, and soft supports 4.2 (which is unmaintained).

# Upgrading from rspec-rails 3.x to version 4

RSpec Rails 4 was the first version to be released out of step with rspec, as a major version under semantic versioning, it allowed us to change the supported Rails versions to 5 and 6 only.
There are no changes required to upgrade to RSpec Rails 4 from 3.x if you are using Rails 5 or 6.

If you are using Rails 4.2 you can use RSpec Rails 4, but note that support for it is not maintained, we consider this a breaking change hence the version change, and you must be on Ruby 2.2 as a minimum.

If you are upgrading from an earlier version of RSpec Rails, please consult [the upgrading 2.x to 3.x guide](https://web.archive.org/web/20220124160827/https://relishapp.com/rspec/rspec-rails/v/3-9/docs/upgrade).
