<!---
This file was generated on 2015-07-24T23:16:02-07:00 from the rspec-dev repo.
DO NOT modify it by hand as your changes will get lost the next time it is generated.
-->

# Development Setup

Generally speaking, you only need to clone the project and install
the dependencies with [Bundler](http://bundler.io/). You can either
get a full RSpec development environment using
[rspec-dev](https://github.com/rspec/rspec-dev#README) or you can
set this project up individually.

## Using rspec-dev

See the [rspec-dev README](https://github.com/rspec/rspec-dev#README)
for setup instructions.

The rspec-dev project contains many rake tasks for helping manage
an RSpec development environment, making it easy to do things like:

* Change branches across all repos
* Update all repos with the latest code from `master`
* Cut a new release across all repos
* Push out updated build scripts to all repos

These sorts of tasks are essential for the RSpec maintainers but will
probably be unnecessary complexity if you're just contributing to one
repository. If you are getting setup to make your first contribution,
we recommend you take the simpler route of setting up rspec-rails
individually.

## Setting up rspec-rails individually

Clone the repo:

```
$ git clone git@github.com:rspec/rspec-rails.git
```

Install the dependencies using [Bundler](http://bundler.io/):

```
$ cd rspec-rails
$ bundle install
```

For reasons discussed below, our CI builds avoid loading Bundler at runtime
by using Bundler's [`--standalone option`](http://myronmars.to/n/dev-blog/2012/03/faster-test-boot-times-with-bundler-standalone).
While not strictly necessary (many/most of our contributors do not do this!),
if you want to exactly reproduce our CI builds you'll want to do the same:

```
$ bundle install --standalone --binstubs
```

The `--binstubs` option creates the `bin/rspec` file that, like `bundle exec rspec`, will load
all the versions specified in `Gemfile.lock` without loading bundler at runtime!

## Gotcha: Version mismatch from sibling repos

The [../Gemfile] is designed to be flexible and support using
the other RSpec repositories either from a local sibling directory
(e.g. `../rspec-<subproject>`) or, if there is no such directory,
directly from git. This generally does the "right thing", but can
be a gotcha in some situations. For example, if you are setting up
`rspec-core`, and you happen to have an old clone of `rspec-expectations`
in a sibling directory, it'll be used even though it might be months or
years out of date, which can cause confusing failures.

To avoid this problem, you can either `export USE_GIT_REPOS=1` to force
the use of `:git` dependencies instead of local dependencies, or update
the code in the sibling directory. rspec-dev contains rake tasks to
help you keep all repos in sync.

## Extra Gems

If you need additional gems for any tasks---such as `benchmark-ips` for benchmarking
or `byebug` for debugging---you can create a `Gemfile-custom` file containing those
gem declarations. The `Gemfile` evaluates that file if it exists, and it is git-ignored.

# Running the build

The [Travis CI build](https://travis-ci.org/rspec/rspec-rails)
runs many verification steps to prevent regressions and
ensure high-quality code. To run the Travis build locally, run:

```
$ script/run_build
```

# What to Expect

To ensure high, uniform code quality, all code changes (including
changes from the maintainers!) are subject to a pull request code
review. We'll often ask for clarification or suggest alternate ways
to do things. Our code reviews are intended to be a two-way
conversation.

While every user-facing change needs a changelog entry, don't worry
about adding it yourself. Since the changelog changes to frequently,
it tends to be the source of merge conflicts when contributors include
edits in their PRs, so we prefer to add changelog entries ourselves
after merging your PR.

# Adding Docs

RSpec uses [YARD](http://yardoc.org/) for its API documentation. To
ensure the docs render well, we recommend running a YARD server and
viewing your edits in a browser.

To run a YARD server:

```
$ bundle exec yard server --reload

# or, if you installed your bundle with `--standalone --binstubs`:

$ bin/yard server --reload
```

Then navigate to `localhost:8808` to view the rendered docs.

# The CI build, in detail

As mentioned above, RSpec runs many verification steps as part of its CI build.
Let's break this down into the individual steps.

## Specs

RSpec dogfoods itself. It's primary defense against regressions is its spec suite. Run with:

```
$ bundle exec rspec

# or, if you installed your bundle with `--standalone --binstubs`:

$ bin/rspec
```

The spec suite performs a couple extra checks that are worth noting:

* *That all the code is warning-free.* Any individual example that produces output
  to `stderr` will fail. We also have a spec that loads all the `lib` and `spec`
  files in a newly spawned process to detect load-time warnings and fail if there
  are any. RSpec must be warning-free so that users who enable Ruby warnings will
  not get warnings from our code.
* *That only a minimal set of stdlibs are loaded.* Since Ruby makes loaded libraries
  available for use in any context, we want to minimize how many bits of the standard
  library we load and use. Otherwise, RSpec's use of part of the standard library could
  mask a problem where a gem author forgets to load a part of the standard library they
  rely on. The spec suite contains a spec that defines a whitelist of allowed loaded
  stdlibs.

In addition, we use [SimpleCov](https://github.com/colszowka/simplecov)
to measure and enforce test coverage. If the coverage falls below a
project-specific threshold, the build will fail.

## Cukes

RSpec uses [cucumber](https://cucumber.io/) for both acceptance testing and [documentation](https://relishapp.com/rspec). Run with:

```
$ bundle exec cucumber

# or, if you installed your bundle with `--standalone --binstubs`:

$ bin/cucumber
```

## YARD documentation

RSpec uses [YARD](http://yardoc.org/) for API documentation on the [rspec.info site](http://rspec.info/).
Our commitment to [SemVer](htp://semver.org) requires that we explicitly
declare our public API, and our build uses YARD to ensure that every
class, module and method has either been labeled `@private` or has at
least some level of documentation. For new APIs, this forces us to make
an intentional decision about whether or not it should be part of
RSpec's public API or not.

To run the YARD documentation coverage check, run:

```
$ bundle exec yard stats --list-undoc

# or, if you installed your bundle with `--standalone --binstubs`:

$ bin/yard stats --list-undoc
```

We also want to prevent YARD errors or warnings when actually generating
the docs. To check for those, run:

```
$ bundle exec yard doc --no-cache

# or, if you installed your bundle with `--standalone --binstubs`:

$ bin/yard doc --no-cache
```

## Rubocop

We use [Rubocop](https://github.com/bbatsov/rubocop) to enforce style conventions on the project so
that the code has stylistic consistency throughout. Run with:

```
$ bundle exec rubocop lib

# or, if you installed your bundle with `--standalone --binstubs`:

$ bin/rubocop lib
```

Our Rubocop configuration is a work-in-progress, so if you get a failure
due to a Rubocop default, feel free to ask about changing the
configuration. Otherwise, you'll need to address the Rubocop failure,
or, as a measure of last resort, by wrapping the offending code in
comments like `# rubocop:disable SomeCheck` and `# rubocop:enable SomeCheck`.

## Run spec files one-by-one

A fast TDD cycle depends upon being able to run a single spec file,
without the rest of the test suite. While rare, it's fairly easy to
create a situation where a spec passes when the entire suite runs
but fails when its individual file is run. To guard against this,
our CI build runs each spec file individually, using a bit of bash like:

```
for file in `find spec -iname '*_spec.rb'`; do
  echo "Running $file"
  bin/rspec $file -b --format progress
done
```

Since this step boots RSpec so many times, it runs much, much
faster when we can avoid the overhead of bundler. This is a main reason our
CI build installs the bundle with `--standalone --binstubs` and
runs RSpec via `bin/rspec` rather than `bundle exec rspec`.

## Running the spec suite for each of the other repos

While each of the RSpec repos is an independent gem (generally designed
to be usable on its own), there are interdependencies between the gems,
and the specs for each tend to use features from the other gems. We
don't want to merge a pull request for one repo that might break the
build for another repo, so our CI build includes a spec that runs the
spec suite of each of the _other_ project repos. Note that we only run
the spec suite, not the full build, of the other projects, as the spec
suite runs very quickly compared to the full build.

