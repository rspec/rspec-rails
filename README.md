# rspec-rails [![Build Status][]][travis-ci] [![Code Climate][]][code-climate] [![Gem Version][]](gem-version)

`rspec-rails` brings the [RSpec][] testing framework to [Ruby on Rails][]
as a drop-in alternative to its default testing framework, Minitest.

In RSpec, tests are not just scripts that verify your application code.
They’re also specifications (or _specs,_ for short):
detailed explanations of how the application is supposed to behave,
expressed in plain English.

Use **[`rspec-rails` 1.x][]** for Rails 2.x.

[Build Status]: https://secure.travis-ci.org/rspec/rspec-rails.svg?branch=master
[travis-ci]: https://travis-ci.org/rspec/rspec-rails
[Code Climate]: https://codeclimate.com/github/rspec/rspec-rails.svg
[code-climate]: https://codeclimate.com/github/rspec/rspec-rails
[Gem Version]: https://badge.fury.io/rb/rspec-rails.svg
[gem-version]: https://badge.fury.io/rb/rspec-rails
[RSpec]: https://rspec.info/
[Ruby on Rails]: https://rubyonrails.org/
[`rspec-rails` 1.x]: https://github.com/dchelimsky/rspec-rails

## Installation

1. Add `rspec-rails` to **both** the `:development` and `:test` groups
   of your app’s `Gemfile`:

   ```ruby
   # Run against the latest stable release
   group :development, :test do
     gem 'rspec-rails', '~> 3.8'
   end

   # Or, run against the master branch
   # (requires master-branch versions of all related RSpec libraries)
   group :development, :test do
     %w[rspec-core rspec-expectations rspec-mocks rspec-rails rspec-support].each do |lib|
       gem lib, :git => "https://github.com/rspec/#{lib}.git", :branch => 'master'
     end
   end
   ```

   (Adding it to the `:development` group is not strictly necessary,
   but without it, generators and rake tasks must be preceded by `RAILS_ENV=test`.)

2. Then, in your project directory:

   ```sh
   # Download and install
   $ bundle install

   # Generate boilerplate configuration files
   # (check the comments in each generated file for more information)
   $ rails generate rspec:install
         create  .rspec
         create  spec
         create  spec/spec_helper.rb
         create  spec/rails_helper.rb
   ```

## Upgrading

If your project is already using an older version of `rspec-rails`,
upgrade to the latest version with:

```sh
$ bundle update rspec-rails
```

RSpec follows [semantic versioning](https://semver.org/),
which means that “major version” upgrades (_e.g.,_ 2.x → 3.x)
come with **breaking changes**.
If you’re upgrading from version 2.x or below,
read the [`rspec-rails` upgrade notes][] to find out what to watch out for.

Be sure to check the general [RSpec upgrade notes][] as well.

[`rspec-rails` upgrade notes]: https://www.relishapp.com/rspec/rspec-rails/docs/upgrade
[RSpec upgrade notes]: https://relishapp.com/rspec/docs/upgrade

## Usage

### Creating boilerplate specs with `rails generate`

```sh
# RSpec hooks into built-in generators
$ rails generate model user
      invoke  active_record
      create    db/migrate/20181017040312_create_users.rb
      create    app/models/user.rb
      invoke    rspec
      create      spec/models/user_spec.rb

# RSpec also provides its own spec file generators
$ rails generate rspec:model user
      create  spec/models/user_spec.rb

# List all RSpec generators
$ rails generate --help | grep rspec
```

### Running specs

```sh
# Default: Run all spec files (i.e., those matching spec/**/*_spec.rb)
$ bundle exec rspec

# Run all spec files in a single directory (recursively)
$ bundle exec rspec spec/models

# Run a single spec file
$ bundle exec rspec spec/controllers/accounts_controller_spec.rb

# Run a single example from a spec file (by line number)
$ bundle exec rspec spec/controllers/accounts_controller_spec.rb:8

# See all options for running specs
$ bundle exec rspec --help
```

**Optional:** If `bundle exec rspec` is too verbose for you,
you can generate a binstub at `bin/rspec`
and use that instead (Rails 4+ only):

 ```sh
 $ bundle binstubs rspec-core
 ```

## RSpec DSL Basics (or, how do I write a spec?)

In RSpec, application behavior is described
**first in (almost) plain English, then again in test code**, like so:

```ruby
RSpec.describe 'Post' do           #
  context 'before publication' do  # (almost) plain English
    it 'cannot have comments' do   #
      expect { Post.create.comments.create! }.to raise_error(ActiveRecord::RecordInvalid)  # test code
    end
  end
end
```

Running `rspec` will execute this test code,
and then use the plain-English descriptions
to generate a report of where the application
conforms to (or fails to meet) the spec:

```
$ rspec --format documentation spec/models/post_spec.rb

Post
  before publication
    cannot have comments

Failures:

  1) Post before publication cannot have comments
     Failure/Error: expect { Post.create.comments.create! }.to raise_error(ActiveRecord::RecordInvalid)
       expected ActiveRecord::RecordInvalid but nothing was raised
     # ./spec/models/post.rb:4:in `block (3 levels) in <top (required)>'

Finished in 0.00527 seconds (files took 0.29657 seconds to load)
1 example, 1 failure

Failed examples:

rspec ./spec/models/post_spec.rb:3 # Post before publication cannot have comments
```

For an in-depth look at the RSpec DSL, including lots of examples,
read the official Cucumber documentation for [RSpec Core][].

[RSpec Core]: https://relishapp.com/rspec/rspec-core/docs

### Helpful Rails Matchers

In RSpec, assertions are called _expectations,_
and every expectation is built around a _matcher._
When you `expect(a).to eq(b)`, you’re using the `eq` matcher.

In addition to [the matchers that come standard in RSpec][],
here are some extras that make it easier
to test the various parts of a Rails system:

| RSpec matcher            | Delegates to      | Available in                    | Notes                                                    |
| ------------------------ | ----------------- | ------------------------------- | -------------------------------------------------------- |
| [`be_a_new`][]           |                   | all                             | primarily intended for controller specs                  |
| [`render_template`][]    | `assert_template` | request / controller / view     | use with `expect(response).to`                           |
| [`redirect_to`][]        | `assert_redirect` | request / controller            | use with `expect(response).to`                           |
| [`route_to`]             | `assert_routing`  | routing / controller            | replaces `route_for` from version 1.x                    |
| [`be_routable`]          |                   | routing / controller            | usu. for `expect(...).not_to be_routable`                |
| [`have_http_status`][]   |                   | request / controller / feature  |                                                          |
| [`match_array`][]        |                   | all                             | for comparing arrays of ActiveRecord objects             |
| [`have_been_enqueued`][] |                   | all                             | requires config: `ActiveJob::Base.queue_adapter = :test` |
| [`have_enqueued_job`][]  |                   | all                             | requires config: `ActiveJob::Base.queue_adapter = :test` |

Follow the links above for examples of how each matcher is used.

[the matchers that come standard in RSpec]: https://relishapp.com/rspec/rspec-expectations/docs/built-in-matchers
[`be_a_new`]: https://relishapp.com/rspec/rspec-rails/docs/matchers/be-a-new-matcher
[`render_template`]: https://relishapp.com/rspec/rspec-rails/docs/matchers/render-template-matcher
[`redirect_to`]: https://relishapp.com/rspec/rspec-rails/docs/matchers/redirect-to-matcher
[`route_to`]: https://relishapp.com/rspec/rspec-rails/docs/routing-specs/route-to-matcher
[`be_routable`]: https://relishapp.com/rspec/rspec-rails/docs/routing-specs/be-routable-matcher
[`have_http_status`]: https://relishapp.com/rspec/rspec-rails/docs/matchers/have-http-status-matcher
[`match_array`]: https://relishapp.com/rspec/rspec-rails/docs/matchers/activerecord-relation-match-array
[`have_been_enqueued`]: https://relishapp.com/rspec/rspec-rails/docs/matchers/have-been-enqueued-matcher
[`have_enqueued_job`]: https://relishapp.com/rspec/rspec-rails/docs/matchers/have-enqueued-job-matcher

### What else does RSpec Rails add?

For a comprehensive look at RSpec Rails’ features,
read the [official Cucumber documentation][].

[official Cucumber documentation]: https://relishapp.com/rspec/rspec-rails/docs

## What tests should I write?

RSpec Rails defines ten different _types_ of specs
for testing different parts of a typical Rails application.
Each one inherits from one of Rails’ built-in `TestCase` classes,
meaning the helper methods provided by default in Rails tests
are available in RSpec, as well.

  | Spec type      | Corresponding Rails test class        |
  | -------------- | --------------------------------      |
  | [model][]      |                                       |
  | [controller][] | [`ActionController::TestCase`][]      |
  | [mailer][]     | `ActionMailer::TestCase`              |
  | [job][]        |                                       |
  | [view][]       | `ActionView::TestCase`                |
  | [routing][]    |                                       |
  | [helper][]     | `ActionView::TestCase`                |
  | [request][]    | [`ActionDispatch::IntegrationTest`][] |
  | [feature][]    |                                       |
  | [system][]     | [`ActionDispatch::SystemTestCase`][]  |

Follow the links above to see examples of each spec type,
or for official Rails API documentation on the given `TestCase` class.

> **Note: This is not a checklist.**
>
> Ask a hundred developers how to test an application,
> and you’ll get a hundred different answers.
>
> RSpec Rails provides thoughtfully selected features
> to encourage good testing practices, but there’s no “right” way to do it.
> Ultimately, it’s up to you to decide how your test suite will be composed.

When creating a spec file,
assign it a type in the top-level `describe` block, like so:

```ruby
# spec/models/user_spec.rb

RSpec.describe User, type: :model do
...
```

[request]: https://relishapp.com/rspec/rspec-rails/docs/request-specs/request-spec
[feature]: https://www.relishapp.com/rspec/rspec-rails/docs/feature-specs/feature-spec
[system]: https://relishapp.com/rspec/rspec-rails/docs/system-specs/system-spec
[model]: https://www.relishapp.com/rspec/rspec-rails/docs/model-specs
[controller]: https://www.relishapp.com/rspec/rspec-rails/docs/controller-specs
[mailer]: https://relishapp.com/rspec/rspec-rails/docs/mailer-specs
[job]: https://relishapp.com/rspec/rspec-rails/docs/job-specs/job-spec
[view]: https://www.relishapp.com/rspec/rspec-rails/docs/view-specs/view-spec
[routing]: https://www.relishapp.com/rspec/rspec-rails/docs/routing-specs
[helper]: https://www.relishapp.com/rspec/rspec-rails/docs/helper-specs/helper-spec
[`ActionDispatch::IntegrationTest`]: https://api.rubyonrails.org/classes/ActionDispatch/IntegrationTest.html
[`ActionDispatch::SystemTestCase`]: https://api.rubyonrails.org/classes/ActionDispatch/SystemTestCase.html
[`ActionController::TestCase`]: https://api.rubyonrails.org/classes/ActionController/TestCase.html
[in the appropriate folder]: https://relishapp.com/rspec/rspec-rails/docs/directory-structure

### System specs, feature specs, request specs–what’s the difference?

RSpec Rails provides some end-to-end (entire application) testing capability
to specify the interaction with the client.

#### System specs

Also called **acceptance tests**, **browser tests**, or **end-to-end tests**,
system specs test the application from the perspective of a _human client._
The test code walks through a user’s browser interactions,

* `visit '/login'`
* `fill_in 'Name', with: 'jdoe'`

and the expectations revolve around page content.

* `expect(page).to have_text('Welcome')`

Because system specs are a wrapper around Rails’ built-in `SystemTestCase`,
they’re only available on Rails 5.1+.
(Feature specs serve the same purpose, but without this dependency.)

#### Feature specs

Before Rails introduced system testing facilities,
feature specs were the only spec type for end-to-end testing.
While the RSpec team now [officially recommends system specs][] instead,
feature specs are still fully supported, look basically identical,
and work on older versions of Rails.

On the other hand, feature specs require non-trivial configuration
to get some important features working,
like JavaScript testing or making sure each test runs with a fresh DB state.
With system specs, this configuration is provided out-of-the-box.

Like system specs, feature specs require the [Capybara][] gem.
Rails 5.1+ includes it by default as part of system tests,
but if you don’t have the luxury of upgrading,
be sure to add it to the `:test` group of your `Gemfile` first:

```ruby
group :test do
  gem "capybara"
end
```

[officially recommends system specs]: https://rspec.info/blog/2017/10/rspec-3-7-has-been-released/#rails-actiondispatchsystemtest-integration-system-specs
[Capybara]: https://github.com/teamcapybara/capybara

#### Request specs

Request specs are for testing the application
from the perspective of a _machine client._
They begin with an HTTP request and end with the HTTP response,
so they’re faster than feature specs,
but do not examine your app’s UI or JavaScript.

Request specs provide a high-level alternative to controller specs.
In fact, as of RSpec 3.5, both the Rails and RSpec teams
[discourage directly testing controllers][]
in favor of functional tests like request specs.

When writing them, try to answer the question,
“For a given HTTP request (verb + path + parameters),
what HTTP response should the application return?”

[discourage directly testing controllers]: https://rspec.info/blog/2016/07/rspec-3-5-has-been-released/#rails-support-for-rails-5

## Contributing

- [Build details](BUILD_DETAIL.md)
- [Code of Conduct](CODE_OF_CONDUCT.md)
- [Detailed contributing guide](CONTRIBUTING.md)

Once you’ve cloned the repo and [set up the environment](DEVELOPMENT.md),
you can run the specs and Cucumber features, or submit a pull request.

## See Also

### RSpec base libraries

* <https://github.com/rspec/rspec>
* <https://github.com/rspec/rspec-core>
* <https://github.com/rspec/rspec-expectations>
* <https://github.com/rspec/rspec-mocks>

### Recommended third-party extensions

* [FactoryBot](https://github.com/thoughtbot/factory_bot)
* [Capybara](https://github.com/jnicklas/capybara)
  (Included by default in Rails 5.1+.
  Note that [additional configuration is required][] to use the Capybara DSL
  anywhere other than system specs and feature specs.)

  [additional configuration is required]: https://rubydoc.info/gems/rspec-rails/file/Capybara.md
