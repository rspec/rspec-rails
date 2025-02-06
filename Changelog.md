### Development
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v7.1.1...7-1-maintenance)

### 7.1.1 / 2025-02-06
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v7.1.0...v7.1.1)

Bug Fixes:

* Check wether rspec-mocks has been loaded before enabling signature
  verification for `have_enqueued_job` et al (Jon Rowe, rspec/rspec-rails#2823)

### 7.1.0 / 2024-11-09
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v7.0.2...v7.1.0)

Enhancements:

* Improve implicit description for ActionCable matchers `have_broadcasted_to` /
  `have_broadcast`. (Simon Fish, rspec/rspec-rails#2795)
* Comment out `infer_spec_type_from_file_location!` in newly generated
  `rails_helper.rb` files. (Jon Rowe, rspec/rspec-rails#2804)
* Allow turning off active job / mailer argument validation.
  (Oli Peate, rspec/rspec-rails#2808)

### 7.0.2 / 2024-11-09
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v7.0.1...v7.0.2)

Bug Fixes:

* Fix issue with `have_enqueued_mail` when jobs were incorrectly matched due
  to refactoring in rspec/rspec-rails#2780. (David Runger, rspec/rspec-rails#2793)

### 7.0.1 / 2024-09-03
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v7.0.0...v7.0.1)

Bug Fixes:

* Remove mutation of Rails constant in favour of public api. (Petrik de Heus, rspec/rspec-rails#2789)
* Cleanup Rails scaffold for unsupported versions. (Matt Jankowski, rspec/rspec-rails#2790)
* Remove deprecated scaffold that was unintentionally included in 7.0.0
  (Jon Rowe, rspec/rspec-rails#2791)

### 7.0.0 / 2024-09-02
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v6.1.5...v7.0.0)

Enhancements:

* Change default driver for system specs on Rails 7.2 to match its default.
  (Steve Polito, rspec/rspec-rails#2746)
* Verify ActiveJob arguments by comparing to the method signature. (Oli Peate, rspec/rspec-rails#2745)
* Add suggestion to rails_helper.rb to skip when not in test mode. (Glauco Custódio, rspec/rspec-rails#2751)
* Add `at_priority` qualifier to `have_enqueued_job` set of matchers. (mbajur, rspec/rspec-rails#2759)
* Add spec directories to `rails stats` on Rails main / 8.0.0. (Petrik de Heus, rspec/rspec-rails#2781)

### 6.1.5 / 2024-09-02
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v6.1.4...v6.1.5)

Bug Fixes:

* Restore old order of requiring support files. (Franz Liedke, rspec/rspec-rails#2785)
* Prevent running `rake spec:statsetup` on Rails main / 8.0.0. (Petrik de Heus, rspec/rspec-rails#2781)

### 6.1.4 / 2024-08-15
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v6.1.3...v6.1.4)

Bug Fixes:

* Prevent `have_http_status` matcher raising an error when encountering a raw `Rack::MockResponse`.
  (Christophe Bliard, rspec/rspec-rails#2771)
* Move Rails version conditional from index scaffold generated file to template. (Matt Jankowski, rspec/rspec-rails#2777)

### 6.1.3 / 2024-06-19
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v6.1.2...v6.1.3)

Bug Fixes:

* Reset `ActiveSupport::CurrentAttributes` between examples. (Javier Julio, rspec/rspec-rails#2752)
* Fix a broken link in generated mailer previews. (Chiara Núñez, rspec/rspec-rails#2764)
* Fix `have_status_code` behaviour with deprecated status names by delegating
  to `Rack::Utils.status_code/1` to set the expected status code. (Darren Boyd, rspec/rspec-rails#2765)

### 6.1.2 / 2024-03-19
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v6.1.1...v6.1.2)

Bug Fixes:

* Fix generated mailer paths to match Rails convention. (Patrício dos Santos, rspec/rspec-rails#2735)
* Fix class in template for generator specs. (Nicolas Buduroi, rspec/rspec-rails#2744)

### 6.1.1 / 2024-01-25
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v6.1.0...v6.1.1)

Bug Fixes:

* Improved deprecation message for `RSpec::Rails::Configuration.fixture_paths`
  (Benoit Tigeot, rspec/rspec-rails#2720)
* Fix support for namespaced fixtures in Rails 7.1. (Benedikt Deicke, rspec/rspec-rails#2716)

### 6.1.0 / 2023-11-21
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v6.0.4...v6.1.0)

Enhancements:

* Support for Rails 7.1
* Minor tweak to generated `rails_helper.rb` to use `Rails.root.join`.
  (@masato-bkn, Ryo Nakamura, rspec/rspec-rails#2640, rspec/rspec-rails#2678)
* Add `RSpec::Rails::Configuration.fixture_paths` configuration to support
  the matching change to `ActiveRecord::TestFixtures`, previous singular
  form is deprecated and will be removed in Rails 7.2. (Juan Gueçaimburu, rspec/rspec-rails#2673)
* Add `send_email` matcher to match emails rather than specific jobs.
  (Andrei Kaleshka, rspec/rspec-rails#2670)
* When using `render` in view specs, `:locals` will now be merged into the
  default implicit template, allowing `render locals: {...}` style calls.
  (Jon Rowe, rspec/rspec-rails#2686)
* Add support for `Rails.config.action_mailer.preview_paths` on Rails 7.1/
  (Jon Rowe, rspec/rspec-rails#2706)

### 6.0.4 / 2023-11-21
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v6.0.3...v6.0.4)

Bug Fixes:

* Fuzzy match `have_broadcasted_to` so that argument matchers can be used.
  (Timothy Peraza, rspec/rspec-rails#2684)
* Fix fixture warning during `:context` hooks on Rails `main`. (Jon Rowe, rspec/rspec-rails#2685)
* Fix `stub_template` on Rails `main`. (Jon Rowe, rspec/rspec-rails#2685)
* Fix variable name in scaffolded view specs when namespaced. (Taketo Takashima, rspec/rspec-rails#2694)
* Prevent `take_failed_screenshot` producing an additional error through `metadata`
  access. (Jon Rowe, rspec/rspec-rails#2704)
* Use `ActiveSupport::ExecutionContext::TestHelper` on Rails 7+. (Jon Rowe, rspec/rspec-rails#2711)
* Fix leak of templates stubbed with `stub_template` on Rails 7.1. (Jon Rowe, rspec/rspec-rails#2714)

### 6.0.3 / 2023-05-31
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v6.0.2...v6.0.3)

Bug Fixes:

* Set `ActiveStorage::FixtureSet.file_fixture_path` when including file fixture support.
  (Jason Yates, rspec/rspec-rails#2671)
* Allow `broadcast_to` matcher to take Symbols. (@Vagab, rspec/rspec-rails#2680)

### 6.0.2 / 2023-05-04
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v6.0.1...v6.0.2)

Bug Fixes:

* Fix ActionView::PathSet when `render_views` is off for Rails 7.1.
  (Eugene Kenny, Iliana, rspec/rspec-rails#2631)
* Support Rails 7.1's `#fixtures_paths` in example groups (removes a deprecation warning).
  (Nicholas Simmons, rspec/rspec-rails#2664)
* Fix `have_enqueued_job` to properly detect enqueued jobs when other jobs were
  performed inside the expectation block. (Slava Kardakov, Phil Pirozhkov, rspec/rspec-rails#2573)

### 6.0.1 / 2022-10-18
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v6.0.0...v6.0.1)

Bug Fixes:

* Prevent tagged logged support in Rails 7 calling `#name`. (Jon Rowe, rspec/rspec-rails#2625)

### 6.0.0 / 2022-10-10
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v5.1.2...v6.0.0)

Enhancements:

* Support Rails 7
* Template tweaks to remove instance variables from generated specs. (Takuma Ishikawa, rspec/rspec-rails#2599)
* Generators now respects default path configuration option. (@vivekmiyani, rspec/rspec-rails#2508)

Breaking Changes:

* Drop support for Rails below 6.1
* Drop support for Ruby below 2.5 (following supported versions of Rails 6.1)
* Change the order of `after_teardown` from `after` to `around` in system
  specs to improve compatibility with extensions and Capybara. (Tim Diggins, rspec/rspec-rails#2596)

Deprecations:

* Deprecates integration spec generator (`rspec:integration`)
  which was an alias of request spec generator (`rspec:request`)
  (Luka Lüdicke, rspec/rspec-rails#2374)

### 5.1.2 / 2022-04-24
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v5.1.1...v5.1.2)

Bug Fixes:

* Fix controller scaffold templates parameter name.  (Taketo Takashima, rspec/rspec-rails#2591)
* Include generator specs in the inferred list of specs. (Jason Karns, rspec/rspec-rails#2597)

### 5.1.1 / 2022-03-07
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v5.1.0...v5.1.1)

Bug Fixes:

* Properly handle global id serialised arguments in `have_enqueued_mail`.
  (Jon Rowe, rspec/rspec-rails#2578)

### 5.1.0 / 2022-01-26
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v5.0.3...v5.1.0)

Enhancements:

* Make the API request scaffold template more consistent and compatible with
  Rails 6.1. (Naoto Hamada, rspec/rspec-rails#2484)
* Change the scaffold `rails_helper.rb` template to use `require_relative`.
  (Jon Dufresne, rspec/rspec-rails#2528)

### 5.0.3 / 2022-01-26
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v5.0.2...v5.0.3)

Bug Fixes:

* Properly name params in controller and request spec templates when
  using the `--model-name` parameter. (@kenzo-tanaka, rspec/rspec-rails#2534)
* Fix parameter matching with mail delivery job and
  ActionMailer::MailDeliveryJob. (Fabio Napoleoni, rspec/rspec-rails#2516, rspec/rspec-rails#2546)
* Fix Rails 7 `have_enqueued_mail` compatibility (Mikael Henriksson, rspec/rspec-rails#2537, rspec/rspec-rails#2546)

### 5.0.2 / 2021-08-14
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v5.0.1...v5.0.2)

Bug Fixes:

* Prevent generated job specs from duplicating `_job` in filenames.
  (Nick Flückiger, rspec/rspec-rails#2496)
* Fix `ActiveRecord::TestFixture#uses_transaction` by using example description
  to replace example name rather than example in our monkey patched
  `run_in_transaction?` method.  (Stan Lo, rspec/rspec-rails#2495)
* Prevent keyword arguments being lost when methods are invoked dynamically
  in controller specs. (Josh Cheek, rspec/rspec-rails#2509, rspec/rspec-rails#2514)

### 5.0.1 / 2021-03-18
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v5.0.0...v5.0.1)

Bug Fixes:

* Limit multibyte example descriptions when used in system tests for #method_name
  which ends up as screenshot names etc. (@y-yagi, rspec/rspec-rails#2405, rspec/rspec-rails#2487)

### 5.0.0 / 2021-03-09
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v4.1.1...v5.0.0)

Enhancements:

* Support new #file_fixture_path and new fixture test support code. (Jon Rowe, rspec/rspec-rails#2398)
* Support for Rails 6.1. (Benoit Tigeot, Jon Rowe, Phil Pirozhkov, and more rspec/rspec-rails#2398)

Breaking Changes:

* Drop support for Rails below 5.2.

### 4.1.1 / 2021-03-09

Bug Fixes:

* Remove generated specs when destroying a generated controller.
  (@Naokimi, rspec/rspec-rails#2475)

### 4.1.0 / 2021-03-06

Enhancements:

* Issue a warning when using job matchers with `#at` mismatch on `usec` precision.
  (Jon Rowe, rspec/rspec-rails#2350)
* Generated request specs now have a bare `_spec` suffix instead of `request_spec`.
  (Eloy Espinaco, Luka Lüdicke, rspec/rspec-rails#2355, rspec/rspec-rails#2356, rspec/rspec-rails#2378)
* Generated scaffold now includes engine route helpers when inside a mountable engine.
  (Andrew W. Lee, rspec/rspec-rails#2372)
* Improve request spec "controller" scaffold when no action is specified.
  (Thomas Hareau, rspec/rspec-rails#2399)
* Introduce testing snippets concept (Phil Pirozhkov, Benoit Tigeot, rspec/rspec-rails#2423)
* Prevent collisions with `let(:name)` for Rails 6.1 and `let(:method_name)` on older
  Rails. (Benoit Tigeot, rspec/rspec-rails#2461)

### 4.0.2 / 2020-12-26
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v4.0.1...v4.0.2)

Bug Fixes:

* Indent all extra failure lines output from system specs. (Alex Robbin, rspec/rspec-rails#2321)
* Generated request spec for update now uses the correct let. (Paul Hanyzewski, rspec/rspec-rails#2344)
* Return `true`/`false` from predicate methods in config rather than raw values.
  (Phil Pirozhkov, Jon Rowe, rspec/rspec-rails#2353, rspec/rspec-rails#2354)
* Remove old #fixture_path feature detection code which broke under newer Rails.
  (Koen Punt, Jon Rowe, rspec/rspec-rails#2370)
* Fix an error when `use_active_record` is `false` (Phil Pirozhkov, rspec/rspec-rails#2423)

### 4.0.1 / 2020-05-16
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v4.0.0...v4.0.1)

Bug Fixes:

* Remove warning when calling `driven_by` in system specs. (Aubin Lorieux, rspec/rspec-rails#2302)
* Fix comparison of times for `#at` in job matchers. (Jon Rowe, Markus Doits, rspec/rspec-rails#2304)
* Allow `have_enqueued_mail` to match when a sub class of `ActionMailer::DeliveryJob`
  is set using `<Class>.delivery_job=`. (Atsushi Yoshida rspec/rspec-rails#2305)
* Restore Ruby 2.2.x compatibility. (Jon Rowe, rspec/rspec-rails#2332)
* Add `required_ruby_version` to gem spec. (Marc-André Lafortune, rspec/rspec-rails#2319, rspec/rspec-rails#2338)

### 4.0.0 / 2020-03-24
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.9.1...v4.0.0)

Enhancements:

* Adds support for Rails 6. (Penelope Phippen, Benoit Tigeot, Jon Rowe, rspec/rspec-rails#2071)
* Adds support for JRuby on Rails 5.2 and 6
* Add support for parameterised mailers (Ignatius Reza, rspec/rspec-rails#2125)
* Add ActionMailbox spec helpers and test type (James Dabbs, rspec/rspec-rails#2119)
* Add ActionCable spec helpers and test type (Vladimir Dementyev, rspec/rspec-rails#2113)
* Add support for partial args when using `have_enqueued_mail`
  (Ignatius Reza, rspec/rspec-rails#2118, rspec/rspec-rails#2125)
* Add support for time arguments for `have_enqueued_job` (@alpaca-tc, rspec/rspec-rails#2157)
* Improve path parsing in view specs render options. (John Hawthorn, rspec/rspec-rails#2115)
* Add routing spec template as an option for generating controller specs.
  (David Revelo, rspec/rspec-rails#2134)
* Add argument matcher support to `have_enqueued_*` matchers. (Phil Pirozhkov, rspec/rspec-rails#2206)
* Switch generated templates to use ruby 1.9 hash keys. (Tanbir Hasan, rspec/rspec-rails#2224)
* Add `have_been_performed`/`have_performed_job`/`perform_job` ActiveJob
  matchers (Isaac Seymour, rspec/rspec-rails#1785)
* Default to generating request specs rather than controller specs when
  generating a controller (Luka Lüdicke, rspec/rspec-rails#2222)
* Allow `ActiveJob` matchers `#on_queue` modifier to take symbolic queue names. (Nils Sommer, rspec/rspec-rails#2283)
* The scaffold generator now generates request specs in preference to controller specs.
  (Luka Lüdicke, rspec/rspec-rails#2288)
* Add configuration option to disable ActiveRecord. (Jon Rowe, Phil Pirozhkov, Hermann Mayer, rspec/rspec-rails#2266)
*  Set `ActionDispatch::SystemTesting::Server.silence_puma = true` when running system specs.
  (ta1kt0me, Benoit Tigeot, rspec/rspec-rails#2289)

Bug Fixes:

* `EmptyTemplateHandler.call` now needs to support an additional argument in
  Rails 6. (Pavel Rosický, rspec/rspec-rails#2089)
* Suppress warning from `SQLite3Adapter.represent_boolean_as_integer` which is
  deprecated. (Pavel Rosický, rspec/rspec-rails#2092)
* `ActionView::Template#formats` has been deprecated and replaced by
  `ActionView::Template#format`(Seb Jacobs, rspec/rspec-rails#2100)
* Replace `before_teardown` as well as `after_teardown` to ensure screenshots
  are generated correctly. (Jon Rowe, rspec/rspec-rails#2164)
* `ActionView::FixtureResolver#hash` has been renamed to `ActionView::FixtureResolver#data`.
  (Penelope Phippen, rspec/rspec-rails#2076)
* Prevent `driven_by(:selenium)` being called due to hook precedence.
  (Takumi Shotoku, rspec/rspec-rails#2188)
* Prevent a `WrongScopeError` being thrown during loading fixtures on Rails
  6.1 development version. (Edouard Chin, rspec/rspec-rails#2215)
* Fix Mocha mocking support with `should`. (Phil Pirozhkov, rspec/rspec-rails#2256)
* Restore previous conditional check for setting `default_url_options` in feature
  specs, prevents a `NoMethodError` in some scenarios. (Eugene Kenny, rspec/rspec-rails#2277)
* Allow changing `ActiveJob::Base.queue_adapter` inside a system spec.
  (Jonathan Rochkind, rspec/rspec-rails#2242)
* `rails generate generator` command now creates related spec file (Joel Azemar, rspec/rspec-rails#2217)
* Relax upper `capybara` version constraint to allow for Capybara 3.x (Phil Pirozhkov, rspec/rspec-rails#2281)
* Clear ActionMailer test mailbox after each example (Benoit Tigeot, rspec/rspec-rails#2293)

Breaking Changes:

* Drops support for Rails below 5.0
* Drops support for Ruby below 2.3

### 3.9.1 / 2020-03-10
[Full Changelog](http://github.com/rspec/rspec-rails/compare/v3.9.0...v3.9.1)

Bug Fixes:

* Add missing require for have_enqueued_mail matcher. (Ignatius Reza, rspec/rspec-rails#2117)

### 3.9.0 / 2019-10-08
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.8.3...v3.9.0)

Enhancements

* Use `__dir__` instead of `__FILE__` in generated `rails_helper.rb` where
  supported. (OKURA Masafumi, rspec/rspec-rails#2048)
* Add `have_enqueued_mail` matcher as a "super" matcher to the `ActiveJob` matchers
  making it easier to match on `ActiveJob` delivered emails. (Joel Lubrano, rspec/rspec-rails#2047)
* Add generator for system specs on Rails 5.1 and above. (Andrzej Sliwa, rspec/rspec-rails#1933)
* Add generator for generator specs. (@ConSou, rspec/rspec-rails#2085)
* Add option to generate routes when generating controller specs. (David Revelo, rspec/rspec-rails#2134)

Bug Fixes:

* Make the `ActiveJob` matchers fail when multiple jobs are queued for negated
  matches. e.g. `expect { job; job; }.to_not have_enqueued_job`.
  (Emric Istanful, rspec/rspec-rails#2069)

### 3.8.3 / 2019-10-03
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.8.2...v3.8.3)

Bug Fixes:

* Namespaced fixtures now generate a `/` separated path rather than an `_`.
  (@nxlith, rspec/rspec-rails#2077)
* Check the arity of `errors` before attempting to use it to generate the `be_valid`
  error message. (Kevin Kuchta, rspec/rspec-rails#2096)

### 3.8.2 / 2019-01-13
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.8.1...v3.8.2)

Bug Fixes:

* Fix issue with generator for preview specs where `Mailer` would be duplicated
  in the name. (Kohei Sugi, rspec/rspec-rails#2037)
* Fix the request spec generator to handle namespaced files. (Kohei Sugi, rspec/rspec-rails#2057)
* Further truncate system test filenames to handle cases when extra words are
  prepended. (Takumi Kaji, rspec/rspec-rails#2058)
* Backport: Make the `ActiveJob` matchers fail when multiple jobs are queued
  for negated matches. e.g. `expect { job; job; }.to_not have_enqueued_job
  (Emric Istanful, rspec/rspec-rails#2069)

### 3.8.1 / 2018-10-23
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.8.0...v3.8.1)

Bug Fixes:

* Fix `NoMethodError: undefined method 'strip'` when using a `Pathname` object
  as the fixture file path. (Aaron Kromer, rspec/rspec-rails#2026)
* When generating feature specs, do not duplicate namespace in the path name.
  (Laura Paakkinen, rspec/rspec-rails#2034)
* Prevent `ActiveJob::DeserializationError` from being issued when `ActiveJob`
  matchers de-serialize arguments. (@aymeric-ledorze, rspec/rspec-rails#2036)

### 3.8.0 / 2018-08-04
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.7.2...v3.8.0)

Enhancements:

* Improved message when migrations are pending in the default `rails_helper.rb`
  (Koichi ITO, rspec/rspec-rails#1924)
* `have_http_status` matcher now supports Rails 5.2 style response symbols
  (Douglas Lovell, rspec/rspec-rails#1951)
* Change generated Rails helper to match Rails standards for Rails.root
  (Alessandro Rodi, rspec/rspec-rails#1960)
* At support for asserting enqueued jobs have no wait period attached.
  (Brad Charna, rspec/rspec-rails#1977)
* Cache instances of `ActionView::Template` used in `stub_template` resulting
  in increased performance due to less allocations and setup. (Simon Coffey, rspec/rspec-rails#1979)
* Rails scaffold generator now respects longer namespaces (e.g. api/v1/\<thing\>).
  (Laura Paakkinen, rspec/rspec-rails#1958)

Bug Fixes:

* Escape quotation characters when producing method names for system spec
  screenshots. (Shane Cavanaugh, rspec/rspec-rails#1955)
* Use relative path for resolving fixtures when `fixture_path` is not set.
  (Laurent Cobos, rspec/rspec-rails#1943)
* Allow custom template resolvers in view specs. (@ahorek, rspec/rspec-rails#1941)


### 3.7.2 / 2017-11-20
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.7.1...v3.7.2)

Bug Fixes:

* Delay loading system test integration until used. (Jon Rowe, rspec/rspec-rails#1903)
* Ensure specs using the aggregate failures feature take screenshots on failure.
  (Matt Brictson, rspec/rspec-rails#1907)

### 3.7.1 / 2017-10-18
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.7.0...v3.7.1)

Bug Fixes:

* Prevent system test integration loading when puma or capybara are missing (Sam Phippen, rspec/rspec-rails#1884)

### 3.7.0 / 2017-10-17
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.6.0...v3.7.0)

Bug Fixes:

* Prevent "template not rendered" log message from erroring in threaded
  environments. (Samuel Cochran, rspec/rspec-rails#1831)
* Correctly generate job name in error message. (Wojciech Wnętrzak, rspec/rspec-rails#1814)

Enhancements:

* Allow `be_a_new(...).with(...)` matcher to accept matchers for
  attribute values. (Britni Alexander, rspec/rspec-rails#1811)
* Only configure RSpec Mocks if it is fully loaded. (James Adam, rspec/rspec-rails#1856)
* Integrate with `ActionDispatch::SystemTestCase`. (Sam Phippen, rspec/rspec-rails#1813)

### 3.6.0 / 2017-05-04
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.6.0.beta2...v3.6.0)

Enhancements:

* Add compatibility for Rails 5.1. (Sam Phippen, Yuichiro Kaneko, rspec/rspec-rails#1790)

Bug Fixes:

* Fix scaffold generator so that it does not generate broken controller specs
  on Rails 3.x and 4.x. (Yuji Nakayama, rspec/rspec-rails#1710)

### 3.6.0.beta2 / 2016-12-12
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.6.0.beta1...v3.6.0.beta2)

Enhancements:

* Improve failure output of ActiveJob matchers by listing queued jobs.
  (Wojciech Wnętrzak, rspec/rspec-rails#1722)
* Load `spec_helper.rb` earlier in `rails_helper.rb` by default.
  (Kevin Glowacz, rspec/rspec-rails#1795)

### 3.6.0.beta1 / 2016-10-09
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.5.2...v3.6.0.beta1)

Enhancements:

* Add support for `rake notes` in Rails `>= 5.1`. (John Meehan, rspec/rspec-rails#1661)
* Remove `assigns` and `assert_template` from scaffold spec generators (Josh
  Justice, rspec/rspec-rails#1689)
* Add support for generating scaffolds for api app specs. (Krzysztof Zych, rspec/rspec-rails#1685)

### 3.5.2 / 2016-08-26
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.5.1...v3.5.2)

Bug Fixes:

* Stop unnecessarily loading `rspec/core` from `rspec/rails` to avoid
  IRB context warning. (Myron Marston, rspec/rspec-rails#1678)
* Deserialize arguments within ActiveJob matchers correctly.
  (Wojciech Wnętrzak, rspec/rspec-rails#1684)

### 3.5.1 / 2016-07-08
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.5.0...v3.5.1)

Bug Fixes:

* Only attempt to load `ActionDispatch::IntegrationTest::Behavior` on Rails 5,
  and above; Prevents possible `TypeError` when an existing `Behaviour` class
  is defined. (#1660, Betesh).

### 3.5.0 / 2016-07-01
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.5.0.beta4...v3.5.0)

**No user facing changes since beta4**

### 3.5.0.beta4 / 2016-06-05
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.5.0.beta3...v3.5.0.beta4)

Enhancements:

* Add support for block when using `with` on `have_enqueued_job`. (John Schroeder, rspec/rspec-rails#1578)
* Add support for `file_fixture(...)`. (Wojciech Wnętrzak, rspec/rspec-rails#1587)
* Add support for `setup` and `teardown` with blocks (Miklós Fazekas, rspec/rspec-rails#1598)
* Add `enqueue_job ` alias for `have_enqueued_job`, support `once`/`twice`/
  `thrice`, add `have_been_enqueued` matcher to support use without blocks.
  (Sergey Alexandrovich, rspec/rspec-rails#1613)

Bug fixes:

* Prevent asset helpers from taking precedence over route helpers. (Prem Sichanugrist, rspec/rspec-rails#1496)
* Prevent `NoMethodError` during failed `have_rendered` assertions on weird templates.
  (Jon Rowe, rspec/rspec-rails#1623).

### 3.5.0.beta3 / 2016-04-02
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.5.0.beta2...v3.5.0.beta3)

Enhancements:

* Add support for Rails 5 Beta 3 (Sam Phippen, Benjamin Quorning, Koen Punt, rspec/rspec-rails#1589, rspec/rspec-rails#1573)

Bug fixes:

* Support custom resolvers when preventing views from rendering.
  (Jon Rowe, Benjamin Quorning, rspec/rspec-rails#1580)

### 3.5.0.beta2 / 2016-03-10
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.5.0.beta1...v3.5.0.beta2)

Enhancements:

* Include `ActionDispatch::IntegrationTest::Behavior` in request spec
  example groups when on Rails 5, allowing integration test helpers
  to be used in request specs. (Scott Bronson, rspec/rspec-rails#1560)

Bug fixes:

* Make it possible to use floats in auto generated (scaffold) tests.
  (Alwahsh, rspec/rspec-rails#1550)

### 3.5.0.beta1 / 2016-02-06
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.4.2...v3.5.0.beta1)

Enhancements:

* Add a `--singularize` option for the feature spec generator (Felicity McCabe,
  rspec/rspec-rails#1503)
* Prevent leaking TestUnit methods in Rails 4+ (Fernando Seror Garcia, rspec/rspec-rails#1512)
* Add support for Rails 5 (Sam Phippen, rspec/rspec-rails#1492)

Bug fixes:

* Make it possible to write nested specs within helper specs on classes that are
  internal to helper classes. (Sam Phippen, Peter Swan, rspec/rspec-rails#1499).
* Warn if a fixture method is called from a `before(:context)` block, instead of
  crashing with a `undefined method for nil:NilClass`. (Sam Phippen, rspec/rspec-rails#1501)
* Expose path to view specs (Ryan Clark, Sarah Mei, Sam Phippen, rspec/rspec-rails#1402)
* Prevent installing Rails 3.2.22.1 on Ruby 1.8.7. (Jon Rowe, rspec/rspec-rails#1540)
* Raise a clear error when `have_enqueued_job` is used with non-test
  adapter. (Wojciech Wnętrzak, rspec/rspec-rails#1489)

### 3.4.2 / 2016-02-02
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.4.1...v3.4.2)

Bug Fixes:

* Cache template resolvers during path lookup to prevent performance
  regression from rspec/rspec-rails#1535. (Andrew White, rspec/rspec-rails#1544)

### 3.4.1 / 2016-01-25
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.4.0...v3.4.1)

Bug Fixes:

* Fix no method error when rendering templates with explicit `:file`
  parameters for Rails version `4.2.5.1`. (Andrew White, Sam Phippen, rspec/rspec-rails#1535)

### 3.4.0 / 2015-11-11
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.3.3...v3.4.0)

Enhancements:

* Improved the failure message for `have_rendered` matcher on a redirect
  response. (Alex Egan, rspec/rspec-rails#1440)
* Add configuration option to filter out Rails gems from backtraces.
  (Bradley Schaefer, rspec/rspec-rails#1458)
* Enable resolver cache for view specs for a large speed improvement
  (Chris Zetter, rspec/rspec-rails#1452)
* Add `have_enqueued_job` matcher for checking if a block has queued jobs.
  (Wojciech Wnętrzak, rspec/rspec-rails#1464)

Bug Fixes:

* Fix another load order issued which causes an undefined method `fixture_path` error
  when loading rspec-rails after a spec has been created. (Nikki Murray, rspec/rspec-rails#1430)
* Removed incorrect surrounding whitespace in the rspec-rails backtrace
  exclusion pattern for its own `lib` code. (Jam Black, rspec/rspec-rails#1439)

### 3.3.3 / 2015-07-15
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.3.2...v3.3.3)

Bug Fixes:

* Fix issue with generators caused by `Rails.configuration.hidden_namespaces`
  including symbols. (Dan Kohn, rspec/rspec-rails#1414)

### 3.3.2 / 2015-06-18
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.3.1...v3.3.2)

Bug Fixes:

* Fix regression that caused stubbing abstract ActiveRecord model
  classes to trigger internal errors in rails due the the verifying
  double lifecycle wrongly calling `define_attribute_methods` on the
  abstract AR class. (Jon Rowe, rspec/rspec-rails#1396)

### 3.3.1 / 2015-06-14
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.3.0...v3.3.1)

Bug Fixes:

* Fix regression that caused stubbing ActiveRecord model classes to
  trigger internal errors in rails. (Myron Marston, Aaron Kromer, rspec/rspec-rails#1395)

### 3.3.0 / 2015-06-12
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.2.3...v3.3.0)

Enhancements:

* Add support for PATCH to route specs created via scaffold. (Igor Zubkov, rspec/rspec-rails#1336)
* Improve controller and routing spec calls to `routes` by using `yield`
  instead of `call`. (Anton Davydov, rspec/rspec-rails#1308)
* Add support for `ActiveJob` specs as standard `RSpec::Rails::RailsExampleGroup`s
  via both `type: :job` and inferring type from spec directory `spec/jobs`.
  (Gabe Martin-Dempesy, rspec/rspec-rails#1361)
* Include `RSpec::Rails::FixtureSupport` into example groups using metadata
  `use_fixtures: true`. (Aaron Kromer, rspec/rspec-rails#1372)
* Include `rspec:request` generator for generating request specs; this is an
  alias of `rspec:integration` (Aaron Kromer, rspec/rspec-rails#1378)
* Update `rails_helper` generator with a default check to abort the spec run
  when the Rails environment is production. (Aaron Kromer, rspec/rspec-rails#1383)

### 3.2.3 / 2015-06-06
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.2.2...v3.2.3)

Bug Fixes:

* Fix regression with the railtie resulting in undefined method `preview_path=`
  on Rails 3.x and 4.0 (Aaron Kromer, rspec/rspec-rails#1388)

### 3.2.2 / 2015-06-03
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.2.1...v3.2.2)

Bug Fixes:

* Fix auto-including of generic `Helper` object for view specs sitting in the
  `app/views` root (David Daniell, rspec/rspec-rails#1289)
* Remove pre-loading of ActionMailer in the Railtie (Aaron Kromer, rspec/rspec-rails#1327)
* Fix undefined method `need_auto_run=` error when using Ruby 2.1 and Rails 3.2
  without the test-unit gem (Orien Madgwick, rspec/rspec-rails#1350)
* Fix load order issued which causes an undefined method `fixture_path` error
  when loading rspec-rails after a spec has been created. (Aaron Kromer, rspec/rspec-rails#1372)

### 3.2.1 / 2015-02-23
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.2.0...v3.2.1)

Bug Fixes:

* Add missing `require` to RSpec generator root fixing an issue where Rail's
  autoload does not find it in some environments. (Aaron Kromer, rspec/rspec-rails#1305)
* `be_routable` matcher now has the correct description. (Tony Ta, rspec/rspec-rails#1310)
* Fix dependency to allow Rails 4.2.x patches / pre-releases (Lucas Mazza, rspec/rspec-rails#1318)
* Disable the `test-unit` gem's autorunner on projects running Rails < 4.1 and
  Ruby < 2.2 (Aaron Kromer, rspec/rspec-rails#1320)

### 3.2.0 / 2015-02-03
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.1.0...v3.2.0)

Enhancements:

* Include generator for `ActionMailer` mailer previews (Takashi Nakagawa, rspec/rspec-rails#1185)
* Configure the `ActionMailer` preview path via a Railtie (Aaron Kromer, rspec/rspec-rails#1236)
* Show all RSpec generators when running `rails generate` (Eliot Sykes, rspec/rspec-rails#1248)
* Support Ruby 2.2 with Rails 3.2 and 4.x (Aaron Kromer, rspec/rspec-rails#1264, rspec/rspec-rails#1277)
* Improve `instance_double` to support verifying dynamic column methods defined
  by `ActiveRecord` (Jon Rowe, rspec/rspec-rails#1238)
* Mirror the use of Ruby 1.9 hash syntax for the `type` tags in the spec
  generators on Rails 4. (Michael Stock, rspec/rspec-rails#1292)

Bug Fixes:

* Fix `rspec:feature` generator to use `RSpec` namespace preventing errors when
  monkey-patching is disabled. (Rebecca Skinner, rspec/rspec-rails#1231)
* Fix `NoMethodError` caused by calling `RSpec.feature` when Capybara is not
  available or the Capybara version is < 2.4.0. (Aaron Kromer, rspec/rspec-rails#1261)
* Fix `ArgumentError` when using an anonymous controller which inherits an
  outer group's anonymous controller. (Yuji Nakayama, rspec/rspec-rails#1260)
* Fix "Test is not a class (TypeError)" error when using a custom `Test` class
  in Rails 4.1 and 4.2. (Aaron Kromer, rspec/rspec-rails#1295)

### 3.1.0 / 2014-09-04
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.0.2...v3.1.0)

Enhancements:

* Switch to using the `have_http_status` matcher in spec generators. (Aaron Kromer, rspec/rspec-rails#1086)
* Update `rails_helper` generator to allow users to opt-in to auto-loading
  `spec/support` files instead of forcing it upon them. (Aaron Kromer, rspec/rspec-rails#1137)
* Include generator for `ActiveJob`. (Abdelkader Boudih, rspec/rspec-rails#1155)
* Improve support for non-ActiveRecord apps by not loading ActiveRecord related
  settings in the generated `rails_helper`. (Aaron Kromer, rspec/rspec-rails#1150)
* Remove Ruby warnings as a suggested configuration. (Aaron Kromer, rspec/rspec-rails#1163)
* Improve the semantics of the controller spec for scaffolds. (Griffin Smith, rspec/rspec-rails#1204)
* Use `#method` syntax in all generated controller specs. (Griffin Smith, rspec/rspec-rails#1206)

Bug Fixes:

* Fix controller route lookup for Rails 4.2. (Tomohiro Hashidate, rspec/rspec-rails#1142)

### 3.0.2 / 2014-07-21
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.0.1...v3.0.2)

Bug Fixes:

* Suppress warning in `SetupAndTeardownAdapter`. (André Arko, rspec/rspec-rails#1085)
* Remove dependency on Rubygems. (Andre Arko & Doc Riteze, rspec/rspec-rails#1099)
* Standardize controller spec template style. (Thomas Kriechbaumer, rspec/rspec-rails#1122)

### 3.0.1 / 2014-06-02
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.0.0...v3.0.1)

Bug Fixes:

* Fix missing require in `rails g rspec:install`. (Sam Phippen, rspec/rspec-rails#1058)

### 3.0.0 / 2014-06-01
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.0.0.rc1...v3.0.0)

Enhancements:

* Separate RSpec configuration in generated `spec_helper` from Rails setup
  and associated configuration options. Moving Rails specific settings and
  options to `rails_helper`. (Aaron Kromer)

Bug Fixes:

* Fix an issue with fixture support when `ActiveRecord` isn't loaded. (Jon Rowe)

### 3.0.0.rc1 / 2014-05-18
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.0.0.beta2...v3.0.0.rc1)

Breaking Changes for 3.0.0:

* Extracts the `mock_model` and `stub_model` methods to the
  `rspec-activemodel-mocks` gem. (Thomas Holmes)
* Spec types are no longer inferred by location, they instead need to be
  explicitly tagged. The old behaviour is enabled by
  `config.infer_spec_type_from_file_location!`, which is still supplied
  in the default generated `spec_helper.rb`. (Xavier Shay, Myron Marston)
* `controller` macro in controller specs no longer mutates
  `:described_class` metadata. It still overrides the subject and sets
  the controller, though. (Myron Marston)
* Stop depending on or requiring `rspec-collection_matchers`. Users who
  want those matchers should add the gem to their Gemfile and require it
  themselves. (Myron Marston)
* Removes runtime dependency on `ActiveModel`. (Rodrigo Rosenfeld Rosas)

Enhancements:

* Supports Rails 4.x reference attribute ids in generated scaffold for view
  specs. (Giovanni Cappellotto)
* Add `have_http_status` matcher. (Aaron Kromer)
* Add spec type metadata to generator templates. (Aaron Kromer)

Bug Fixes:

* Fix an inconsistency in the generated scaffold specs for a controller. (Andy Waite)
* Ensure `config.before(:all, type: <type>)` hooks run before groups
  of the given type, even when the type is inferred by the file
  location. (Jon Rowe, Myron Marston)
* Switch to parsing params with `Rack::Utils::parse_nested_query` to match Rails.
  (Tim Watson)
* Fix incorrect namespacing of anonymous controller routes. (Aaron Kromer)

### 3.0.0.beta2 / 2014-02-17
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v3.0.0.beta1...v3.0.0.beta2)

Breaking Changes for 3.0.0:

* Removes the `--webrat` option for the request spec generator (Andy Lindeman)
* Methods from `Capybara::DSL` (e.g., `visit`) are no longer available in
  controller specs. It is more appropriate to use capybara in feature specs
  (`spec/features`) instead. (Andy Lindeman)
* `infer_base_class_for_anonymous_controllers` is
  enabled by default. (Thomas Holmes)
* Capybara 2.2.0 or above is required for feature specs. (Andy Lindeman)

Enhancements:

* Improve `be_valid` matcher for non-ActiveModel::Errors implementations (Ben Hamill)

Bug Fixes:

* Use `__send__` rather than `send` to prevent naming collisions (Bradley Schaefer)
* Supports Rails 4.1. (Andy Lindeman)
* Routes are drawn correctly for anonymous controllers with abstract
  parents. (Billy Chan)
* Loads ActiveSupport properly to support changes in Rails 4.1. (Andy Lindeman)
* Anonymous controllers inherit from `ActionController::Base` if `ApplicationController`
  is not present. (Jon Rowe)
* Require `rspec/collection_matchers` when `rspec/rails` is required. (Yuji Nakayama)

### 3.0.0.beta1 / 2013-11-07
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.99.0...v3.0.0.beta1)

Breaking Changes for 3.0.0:

* Extracts `autotest` and `autotest-rails` support to `rspec-autotest` gem.
  (Andy Lindeman)

### 2.99.0 / 2014-06-01
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.99.0.rc1...v2.99.0)

No changes. Just taking it out of pre-release.

### 2.99.0.rc1 / 2014-05-18
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.99.0.beta2...v2.99.0.rc1)

Deprecations

* Deprecates `stub_model` and `mock_model` in favor of the
  `rspec-activemodel-mocks` gem. (Thomas Holmes)
* Issue a deprecation to instruct users to configure
  `config.infer_spec_type_from_file_location!` during the
  upgrade process since spec type inference is opt-in in 3.0.
  (Jon Rowe)
* Issue a deprecation when `described_class` is accessed in a controller
  example group that has used the `controller { }` macro to generate an
  anonymous controller class, since in 2.x, `described_class` would
  return that generated class but in 3.0 it will continue returning the
  class passed to `describe`. (Myron Marston)

### 2.99.0.beta2 / 2014-02-17
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.99.0.beta1...v2.99.0.beta2)

Deprecations:

* Deprecates the `--webrat` option to the scaffold and request spec generator (Andy Lindeman)
* Deprecates the use of `Capybara::DSL` (e.g., `visit`) in controller specs.
  It is more appropriate to use capybara in feature specs (`spec/features`)
  instead. (Andy Lindeman)

Bug Fixes:

* Use `__send__` rather than `send` to prevent naming collisions (Bradley Schaefer)
* Supports Rails 4.1. (Andy Lindeman)
* Loads ActiveSupport properly to support changes in Rails 4.1. (Andy Lindeman)
* Anonymous controllers inherit from `ActionController::Base` if `ApplicationController`
  is not present. (Jon Rowe)

### 2.99.0.beta1 / 2013-11-07
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.14.0...v2.99.0.beta1)

Deprecations:

* Deprecates autotest integration in favor of the `rspec-autotest` gem. (Andy
  Lindeman)

Enhancements:

* Supports Rails 4.1 and Minitest 5. (Patrick Van Stee)

Bug Fixes:

* Fixes "warning: instance variable @orig\_routes not initialized" raised by
  controller specs when `--warnings` are enabled. (Andy Lindeman)
* Where possible, check against the version of ActiveRecord, rather than
  Rails. It is possible to use some of rspec-rails without all of Rails.
  (Darryl Pogue)
* Explicitly depends on `activemodel`. This allows libraries that do not bring
  in all of `rails` to use `rspec-rails`. (John Firebaugh)

### 2.14.1 / 2013-12-29
[full changelog](https://github.com/rspec/rspec-rails/compare/v2.14.0...v2.14.1)

Bug Fixes:

* Fixes "warning: instance variable @orig\_routes not initialized" raised by
  controller specs when `--warnings` are enabled. (Andy Lindeman)
* Where possible, check against the version of ActiveRecord, rather than
  Rails. It is possible to use some of rspec-rails without all of Rails.
  (Darryl Pogue)
* Supports Rails 4.1 and Minitest 5. (Patrick Van Stee, Andy Lindeman)
* Explicitly depends on `activemodel`. This allows libraries that do not bring
  in all of `rails` to use `rspec-rails`. (John Firebaugh)
* Use `__send__` rather than `send` to prevent naming collisions (Bradley Schaefer)

### 2.14.0 / 2013-07-06
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.14.0.rc1...v2.14.0)

Bug fixes

* Rake tasks do not define methods that might interact with other libraries.
  (Fujimura Daisuke)
* Reverts fix for out-of-order `let` definitions in controller specs after the
  issue was fixed upstream in rspec-core. (Andy Lindeman)
* Fixes deprecation warning when using `expect(Model).to have(n).records` with
  Rails 4. (Andy Lindeman)

### 2.14.0.rc1 / 2013-05-27
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.13.2...v2.14.0.rc1)

Enhancements

* Prelimiarily support Rails 4.1 by updating adapters to support Minitest 5.0.
  (Andy Lindeman)

Bug fixes

* `rake stats` runs correctly when spec files exist at the top level of the
  spec/ directory. (Benjamin Fleischer)

### 2.13.2 / 2013-05-18
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.13.1...v2.13.2)

Bug fixes

* `let` definitions may override methods defined in modules brought in via
  `config.include` in controller specs. Fixes regression introduced in 2.13.
  (Andy Lindeman, Jon Rowe)
* Code that checks Rails version numbers is more robust in cases where Rails is
  not fully loaded. (Andy Lindeman)

Enhancements

* Document how the spec/support directory works. (Sam Phippen)

### 2.13.1 / 2013-04-27
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.13.0...v2.13.1)

Bug fixes

* View specs are no longer generated if no template engine is specified (Kevin
  Glowacz)
* `ActionController::Base.allow_forgery_protection` is set to its original
  value after each example. (Mark Dimas)
* `patch` is supported in routing specs. (Chris Your)
* Routing assertions are supported in controller specs in Rails 4. (Andy
  Lindeman)
* Fix spacing in the install generator template (Taiki ONO)

### 2.13.0 / 2013-02-23
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.12.2...v2.13.0)

Enhancements

* `be_valid` matcher includes validation error messages. (Tom Scott)
* Adds cucumber scenario showing how to invoke an anonymous controller's
  non-resourceful actions. (Paulo Luis Franchini Casaretto)
* Null template handler is used when views are stubbed. (Daniel Schierbeck)
* The generated `spec_helper.rb` in Rails 4 includes a check for pending
  migrations. (Andy Lindeman)
* Adds `rake spec:features` task. (itzki)
* Rake tasks are automatically generated for each spec/ directory.
  (Rudolf Schmidt)

### 2.12.2 / 2013-01-12
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.12.1...v2.12.2)

Bug fixes

* Reverts earlier fix where anonymous controllers defined the `_routes` method
  to support testing of redirection and generation of URLs from other contexts.
  The implementation ended up breaking the ability to refer to non-anonymous
  routes in the context of the controller under test.
* Uses `assert_select` correctly in view specs generated by scaffolding. (Andy
  Lindeman)

### 2.12.1 / 2013-01-07
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.12.0...v2.12.1)

Bug fixes

* Operates correctly when ActiveRecord is only partially loaded (e.g., with
  older versions of Mongoid). (Eric Marden)
* `expect(subject).to have(...).errors_on` operates correctly for
  ActiveResource models where `valid?` does not accept an argument. (Yi Wen)
* Rails 4 support for routing specs. (Andy Lindeman)
* Rails 4 support for `ActiveRecord::Relation` and the `=~` operator matcher.
  (Andy Lindeman)
* Anonymous controllers define `_routes` to support testing of redirection
  and generation of URLs from other contexts. (Andy Lindeman)

### 2.12.0 / 2012-11-12
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.11.4...v2.12.0)

Enhancements

* Support validation contexts when using `#errors_on` (Woody Peterson)
* Include RequestExampleGroup in groups in spec/api

Bug fixes

* Add `should` and `should_not` to `CollectionProxy` (Rails 3.1+) and
  `AssociationProxy` (Rails 3.0).  (Myron Marston)
* `controller.controller_path` is set correctly for view specs in Rails 3.1+.
  (Andy Lindeman)
* Generated specs support module namespacing (e.g., in a Rails engine).
  (Andy Lindeman)
* `render` properly infers the view to be rendered in Rails 3.0 and 3.1
  (John Firebaugh)
* AutoTest mappings involving config/ work correctly (Brent J. Nordquist)
* Failures message for `be_new_record` are more useful (Andy Lindeman)

### 2.11.4 / 2012-10-14
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.11.0...v2.11.4)

Capybara-2.0 integration support:

* include RailsExampleGroup in spec/features (necessary when there is no AR)
* include Capybara::DSL and Capybara::RSpecMatchers in spec/features

See [https://github.com/jnicklas/capybara/pull/809](https://github.com/jnicklas/capybara/pull/809)
and [https://rubydoc.info/gems/rspec-rails/file/Capybara.md](https://rubydoc.info/gems/rspec-rails/file/Capybara.md)
for background.

2.11.1, .2, .3 were yanked due to errant documentation.

### 2.11.0 / 2012-07-07
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.10.1...v2.11.0)

Enhancements

* The generated `spec/spec_helper.rb` sets `config.order = "random"` so that
  specs run in random order by default.
* rename `render_template` to `have_rendered` (and alias to `render_template`
  for backward compatibility)
* The controller spec generated with `rails generate scaffold namespaced::model`
  matches the spec generated with `rails generate scaffold namespaced/model`
  (Kohei Hasegawa)

Bug fixes

* "uninitialized constant" errors are avoided when using using gems like
  `rspec-rails-uncommitted` that define `Rspec::Rails` before `rspec-rails`
  loads (Andy Lindeman)

### 2.10.1 / 2012-05-03
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.10.0...v2.10.1)

Bug fixes

* fix regression introduced in 2.10.0 that broke integration with Devise
  (https://github.com/rspec/rspec-rails/issues/534)
* remove generation of helper specs when running the scaffold generator, as
  Rails already does this (Jack Dempsey)

### 2.10.0 / 2012-05-03
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.9.0...v2.10.0)

Bug fixes

* `render_views` called in a spec can now override the config setting. (martinsvalin)
* Fix `render_views` for anonymous controllers on 1.8.7. (hudge, mudge)
* Eliminate use of deprecated `process_view_paths`
* Fix false negatives when using `route_to` matcher with `should_not`
* `controller` is no longer nil in `config.before` hooks
* Change `request.path_parameters` keys to symbols to match real Rails
  environment (Nathan Broadbent)
* Silence deprecation warnings in pre-2.9 generated view specs (Jonathan del
  Strother)

### 2.9.0 / 2012-03-17
[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.8.1...v2.9.0)

Enhancements

* add description method to RouteToMatcher (John Wulff)
* Run "db:test:clone_structure" instead of "db:test:prepare" if Active Record's
  schema format is ":sql". (Andrey Voronkov)

Bug fixes

* `mock_model(XXX).as_null_object.unknown_method` returns self again
* Generated view specs use different IDs for each attribute.

### 2.8.1 / 2012-01-04

[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.8.0...v2.8.1)

NOTE: there was a change in rails-3.2.0.rc2 which broke compatibility with
stub_model in rspec-rails. This release fixes that issue, but it means that
you'll have to upgrade to rspec-rails-2.8.1 when you upgrade to rails >=
3.2.0.rc2.

* Bug fixes
    * Explicitly stub valid? in stub_model. Fixes stub_model for rails versions
      >= 3.2.0.rc2.

### 2.8.0 / 2012-01-04

[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.8.0.rc2...v2.8.0)

* Enhancements
    * Eliminate deprecation warnings in generated view specs in Rails 3.2
    * Ensure namespaced helpers are included automatically (Evgeniy Dolzhenko)
    * Added cuke scenario documenting which routes are generated for anonymous
      controllers (Alan Shields)

### 2.8.0.rc2 / 2011-12-19

[Full Changelog](https://github.com/rspec/rspec-mocks/compare/v2.8.0.rc1...v2.8.0.rc2)

* Enhancements
    * Add session hash to generated controller specs (Thiago Almeida)
    * Eliminate deprecation warnings about InstanceMethods modules in Rails 3.2

* Bug fixes
    * Stub attribute accessor after `respond_to?` call on mocked model (Igor
      Afonov)

### 2.8.0.rc1 / 2011-11-06

[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.7.0...v2.8.0.rc1)

* Enhancements
    * Removed unnecessary "config.mock_with :rspec" from spec_helper.rb (Paul
      Annesley)

* Changes
    * No API changes for rspec-rails in this release, but some internals
      changed to align with rspec-core-2.8

* [rspec-core](https://github.com/rspec/rspec-core/blob/master/Changelog.md)
* [rspec-expectations](https://github.com/rspec/rspec-expectations/blob/master/Changelog.md)
* [rspec-mocks](https://github.com/rspec/rspec-mocks/blob/master/Changelog.md)

### 2.7.0 / 2011-10-16

[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.6.1...v2.7.0)

* Enhancements
  * `ActiveRecord::Relation` can use the `=~` matcher (Andy Lindeman)
  * Make generated controller spec more consistent with regard to ids
    (Brent J. Nordquist)
  * Less restrictive autotest mapping between spec and implementation files
    (José Valim)
  * `require 'rspec/autorun'` from generated `spec_helper.rb` (David Chelimsky)
  * add `bypass_rescue` (Lenny Marks)
  * `route_to` accepts query string (Marc Weil)

* Internal
  * Added specs for generators using ammeter (Alex Rothenberg)

* Bug fixes
  * Fix configuration/integration bug with rails 3.0 (fixed in 3.1) in which
    `fixure_file_upload` reads from `ActiveSupport::TestCase.fixture_path` and
    misses RSpec's configuration (David Chelimsky)
  * Support nested resource in view spec generator (David Chelimsky)
  * Define `primary_key` on class generated by `mock_model("WithAString")`
    (David Chelimsky)

### 2.6.1 / 2011-05-25

[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.6.0...v2.6.1)

This release is compatible with rails-3.1.0.rc1, but not rails-3.1.0.beta1

* Bug fixes
  * fix controller specs with anonymous controllers with around filters
  * exclude spec directory from rcov metrics (Rodrigo Navarro)
  * guard against calling prerequisites on nil default rake task (Jack Dempsey)

### 2.6.0 / 2011-05-12

[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.5.0...v2.6.0)

* Enhancements
  * rails 3 shortcuts for routing specs (Joe Fiorini)
  * support nested resources in generators (Tim McEwan)
  * require 'rspec/rails/mocks' to use `mock_model` without requiring the whole
    rails framework
  * Update the controller spec generated by the rails scaffold generator:
    * Add documentation to the generated spec
    * Use `any_instance` to avoid stubbing finders
    * Use real objects instead of `mock_model`
  * Update capybara integration to work with capy 0.4 and 1.0.0.beta
  * Decorate paths passed to `[append|prepend]_view_paths` with empty templates
    unless rendering views. (Mark Turner)

* Bug fixes
  * fix typo in "rake spec:statsetup" (Curtis Schofield)
  * expose named routes in anonymous controller specs (Andy Lindeman)
  * error when generating namespaced scaffold resources (Andy Lindeman)
  * Fix load order issue w/ Capybara (oleg dashevskii)
  * Fix monkey patches that broke due to internal changes in rails-3.1.0.beta1

### 2.5.0 / 2011-02-05

[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.4.1...v2.5.0)

* Enhancements
  * use index_helper instead of table_name when generating specs (Reza
    Primardiansyah)

* Bug fixes
  * fixed bug in which `render_views` in a nested group set the value in its
    parent group.
  * only include MailerExampleGroup when it is defined (Steve Sloan)
  * mock_model.as_null_object.attribute.blank? returns false (Randy Schmidt)
  * fix typo in request specs (Paco Guzman)

### 2.4.1 / 2011-01-03

[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.4.0...v2.4.1)

* Bug fixes
  * fixed bug caused by including some Rails modules before RSpec's
    RailsExampleGroup

### 2.4.0 / 2011-01-02

[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.3.1...v2.4.0)

* Enhancements
  * include ApplicationHelper in helper object in helper specs
  * include request spec extensions in files in spec/integration
  * include controller spec extensions in groups that use type: :controller
    * same for :model, :view, :helper, :mailer, :request, :routing

* Bug fixes
  * restore global config.render_views so you only need to say it once
  * support overriding render_views in nested groups
  * matchers that delegate to Rails' assertions capture
    ActiveSupport::TestCase::Assertion (so they work properly now with
    should_not in Ruby 1.8.7 and 1.9.1)

* Deprecations
  * include_self_when_dir_matches

### 2.3.1 / 2010-12-16

[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.3.0...v2.3.1)

* Bug fixes
  * respond_to? correctly handles 2 args
  * scaffold generator no longer fails on autotest directory

### 2.3.0 / 2010-12-12

[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.2.1...v2.3.0)

* Changes
  * Generator no longer generates autotest/autodiscover.rb, as it is no longer
    needed (as of rspec-core-2.3.0)

### 2.2.1 / 2010-12-01

[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.2.0...v2.2.1)

* Bug fixes
  * Depend on railties, activesupport, and actionpack instead of rails (Piotr
    Solnica)
  * Got webrat integration working properly across different types of specs

* Deprecations
  * --webrat-matchers flag for generators is deprecated. use --webrat instead.

### 2.2.0 / 2010-11-28

[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.1.0...v2.2.0)

* Enhancements
  * Added stub_template in view specs

* Bug fixes
  * Properly include helpers in views (Jonathan del Strother)
  * Fix bug in which method missing led to a stack overflow
  * Fix stack overflow in request specs with open_session
  * Fix stack overflow in any spec when method_missing was invoked
  * Add gem dependency on rails ~> 3.0.0 (ensures bundler won't install
    rspec-rails-2 with rails-2 apps).

### 2.1.0 / 2010-11-07

[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.0.1...v2.1.0)

* Enhancements
  * Move errors_on to ActiveModel to support other AM-compliant ORMs

* Bug fixes
  * Check for presence of ActiveRecord instead of checking Rails config
    (gets rspec out of the way of multiple ORMs in the same app)

### 2.0.1 / 2010-10-15

[Full Changelog](https://github.com/rspec/rspec-rails/compare/v2.0.0...v2.0.1)

* Enhancements
  * Add option to not generate request spec (--skip-request-specs)

* Bug fixes
  * Updated the mock_[model] method generated in controller specs so it adds
    any stubs submitted each time it is called.
  * Fixed bug where view assigns weren't making it to the view in view specs in Rails-3.0.1.
    (Emanuele Vicentini)

### 2.0.0 / 2010-10-10

[Full Changelog](https://github.com/rspec/rspec-rails/compare/ea6bdef...v2.0.0)

* Enhancements
  * ControllerExampleGroup uses controller as the implicit subject by default (Paul Rosania)
  * autotest mapping improvements (Andreas Neuhaus)
  * more cucumber features (Justin Ko)
  * clean up spec helper (Andre Arko)
  * add assign(name, value) to helper specs (Justin Ko)
  * stub_model supports primary keys other than id (Justin Ko)
  * support choice between Webrat/Capybara (Justin Ko)
  * support specs for 'abstract' subclasses of ActionController::Base (Mike Gehard)
  * be_a_new matcher supports args (Justin Ko)

* Bug fixes
  * support T::U components in mailer and request specs (Brasten Sager)
