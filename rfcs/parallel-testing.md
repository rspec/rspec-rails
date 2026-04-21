# RFC: Rails parallel testing integration

Status: draft
Tracks: [rspec/rspec-rails#2104](https://github.com/rspec/rspec-rails/issues/2104)
Depends on: parallel runner landing in rspec-core (separate RFC in that repo)

## Problem

Rails 6+ ships built-in parallel testing for Minitest via
`ActiveSupport::TestCase.parallelize(workers: :number_of_processors)`. Users
running RSpec on Rails have no native equivalent. The blocker has been
rspec-core itself — it has no parallel runner, so rspec-rails has nothing to
integrate with.

Third-party tools (`turbo_tests`, `flatware`, `parallel_tests`, `rspecq`) fill
the gap with varying tradeoffs, but none ship in the box and all require
out-of-band setup for per-worker databases. The effect: new Rails + RSpec
projects pay a parallel-testing tax that Rails + Minitest projects don't.

## Approach

Once rspec-core exposes a parallel runner with fork-based workers and a hook
lifecycle (see rspec-core RFC), rspec-rails wires Rails' existing
`parallelize_*` hook registry into that lifecycle. Users who already write
`parallelize_setup` / `parallelize_teardown` blocks in `rails_helper.rb` get
the behavior they'd get under Minitest, with zero new rspec-rails-specific
API.

The bridge is wired automatically on `require "rspec/rails"`. No opt-in call
is required: the `parallelize_setup` / `parallelize_teardown` delegators
install unconditionally but only fire when `--parallel` (or a configured
`default_parallel_workers`) actually forks workers. The public
`use_rails_parallel!` method is retained as an idempotent no-op so older
`rails_helper.rb` files that still call it continue to work unchanged, and
as an explicit opt-in for apps that initialize RSpec in a non-standard
order.

## Public API (users)

**No new API in rspec-rails.** Users continue to use Rails' existing verbs
against `ActiveSupport::TestCase`:

```ruby
# rails_helper.rb
ActiveSupport::TestCase.parallelize_setup do |worker|
  # per-worker DB is already set up by ActiveRecord::TestDatabases.
  # Put additional per-worker setup here (e.g. Redis namespaces).
end

ActiveSupport::TestCase.parallelize_teardown do |worker|
  # per-worker cleanup.
end
```

Note: `ActiveSupport::Testing::Parallelization` exposes only `after_fork_hooks`
and `run_cleanup_hooks` — there is no Rails-side `before_fork_hooks` registry.
rspec-core's `parallelize_before_fork` is still available to users directly via
`RSpec.configure`; rspec-rails just has nothing on the Rails side to bridge it
to. ActiveRecord drops connection pools inside its `after_fork_hook` (post-fork,
in each worker) rather than pre-fork on the master.

Invocation matches Minitest parallel behavior:

```sh
bundle exec rspec                  # single-process unless configured default (see below)
bundle exec rspec --parallel 4     # 4 worker processes
bundle exec rspec --parallel       # :number_of_processors
PARALLEL_WORKERS=8 bundle exec rspec --parallel
```

Default is single-process; parallel is opt-in at the command line. Projects
that want parallel to be the default can set it in their config:

```ruby
# spec/spec_helper.rb or rails_helper.rb
RSpec.configure do |c|
  c.default_parallel_workers = :number_of_processors  # or an integer
end
```

With `default_parallel_workers` set, `bundle exec rspec` runs parallel without
`--parallel`. Explicit `--parallel N` on the CLI still overrides, and
`--no-parallel` (or `--parallel 1`) forces single-process. `PARALLEL_WORKERS`
env overrides both. CI systems that share configuration with dev machines but
want single-process locally can unset the config or pass `--no-parallel`.

Inside a spec, the current worker number (or `nil` outside parallel) is
readable via `RSpec.parallel_worker_number` (provided by rspec-core).

## Mechanism (rspec-rails)

A new file `lib/rspec/rails/parallel.rb`, required when `ActiveRecord` is
loaded, registers two delegating hooks against rspec-core's parallel
lifecycle:

```ruby
require "active_record/test_databases"  # force-load so AR's own hook registers

RSpec.configure do |c|
  c.parallelize_setup do |worker_number|
    ActiveSupport::Testing::Parallelization.after_fork_hooks.each { |h| h.call(worker_number) }
  end
  c.parallelize_teardown do |worker_number|
    ActiveSupport::Testing::Parallelization.run_cleanup_hooks.each { |h| h.call(worker_number) }
  end
end
```

The `require "active_record/test_databases"` is load-bearing. AR's module body
registers its own `after_fork_hook` that creates and loads the per-worker
schema (`<database>_<worker_number>`). Without forcing the reference, Rails'
`rails/test_help.rb` is the only loader — and rspec-rails apps don't require
it.

Once registered, the flow is:

1. **Master boots.** `rails_helper.rb` loads, triggers rspec-rails autoload,
   `lib/rspec/rails/parallel.rb` installs the two delegators on
   `RSpec.configuration`. `ActiveRecord::TestDatabases` module body runs,
   registering AR's own `after_fork_hook` on
   `ActiveSupport::Testing::Parallelization`.
2. **Fork N workers.** rspec-core forks. Each worker post-fork fires
   `parallelize_setup(worker_num)`. Our delegator iterates
   `after_fork_hooks`, which includes AR's DB create-and-load
   (`<database>_<worker_num>`) and any user-registered `parallelize_setup`
   block from `rails_helper.rb`.
3. **Workers run tests.** Each has its own DB, connection, worker number.
4. **Worker exit.** `parallelize_teardown(worker_num)` fires. Our delegator
   iterates `run_cleanup_hooks` including any user-registered teardown.

## What this does NOT include

- **System tests with headless browsers.** Per-worker Capybara port
  allocation ships in v1 (see "System tests: port allocation" below).
  Headless-browser-specific concerns (per-worker user-data dirs for Chrome,
  remote driver session isolation) are out of scope and will land in a
  follow-up.
- **Thread-based parallelism.** v1 is fork-only. Rails' threaded parallel
  mode skips DB creation anyway; users wanting threads can still call
  `parallelize(with: :threads)` directly on `ActiveSupport::TestCase`, but
  rspec-core workers won't be threads in v1.
- **Windows.** No `fork` on Windows; rspec-core's shell fallback is a
  future-work item in the core RFC.

## Compatibility

- **Single-process `rspec`:** unchanged. No hooks fire, no parallel code loads.
- **Existing parallel_tests / turbo_tests users:** their tools shell out to
  `rspec` which in single-process mode is unchanged. They can migrate to
  `--parallel` when ready.
- **Rails versions:** requires Rails 6.0+ (first version shipping
  `ActiveSupport::Testing::Parallelization`). Older Rails on rspec-rails
  keeps today's behavior.

## Migration guide (for the changelog)

```ruby
# Before (using parallel_tests gem)
# .rspec_parallel, parallel_tests setup, bin/parallel_rspec ...

# After
bundle exec rspec --parallel

# Your existing parallelize_setup blocks in rails_helper.rb work unchanged.
```

## Generator: new `rails_helper.rb` template

`rails generate rspec:install` enables parallel testing by default,
mirroring `rails new`'s Minitest template (which emits
`parallelize(workers: :number_of_processors)` in `test_helper.rb`):

```ruby
# Run specs in parallel by default when fork is available. Each worker
# runs against its own database (<database>_<worker_number>), per-worker
# logs land in log/test-<worker_number>.log, and Capybara gets a
# per-worker server port. Set to an integer to cap workers, or remove
# this line to make `rspec` serial unless `--parallel` is passed.
config.default_parallel_workers = :number_of_processors if Process.respond_to?(:fork)

# With `use_transactional_fixtures` on, each example already runs inside
# a transaction that rolls back -- so Rails' post-run truncation of every
# table in every per-worker DB is redundant. Uncomment to skip it:
#   ENV['SKIP_TEST_DATABASE_TRUNCATE'] ||= '1'
```

The bridge itself requires no explicit call -- `require "rspec/rails"`
already wires it. Users who want to register custom per-worker setup do
so via the Rails API, same as Minitest:

```ruby
ActiveSupport::TestCase.parallelize_setup do |worker|
  # Redis namespacing, tmpfile dirs, extra service connections, etc.
end
```

## Logging: per-worker log files

Without intervention, every worker inherits the master's `Rails.logger` and
interleaves writes into a single `log/test.log` -- Rails' Minitest integration
doesn't ship a per-worker log-redirect hook; users typically add one by hand
in a `parallelize_setup` block. rspec-rails installs that redirect as part of
the auto-wired bridge: each worker's `Rails.logger` is replaced with a
`TaggedLogging`-wrapped `ActiveSupport::Logger` writing to
`log/test-<worker_number>.log`, preserving the previous logger's formatter
and level. Users should `tail -f log/test-*.log` (or grep across files)
rather than `log/test.log`.

Generator output and README will mention this explicitly.

## System tests: port allocation

Capybara's default server binds a single port, which collides across
workers. rspec-rails will install a worker-aware port assignment in its
`parallelize_setup` hook when Capybara is loaded:

```ruby
# sketch
if defined?(Capybara)
  Capybara.server_port = 9000 + (worker_number * 1000) + rand(1..999)
end
```

The `* 1000 + rand(1..999)` pattern gives each worker a 1000-port band with
collision avoidance inside the band — matches the convention used by
parallel_tests setups in production Rails apps. Base port configurable via
`RSpec.configuration.parallel_server_port_base` (default `9000`) for sites
where the low range is occupied.

## Open questions

1. **Should `default_parallel_workers` live in rspec-rails or rspec-core?**
   Nothing about it is Rails-specific, so it probably belongs in rspec-core's
   parallel RFC. Flagging here so we decide once, not twice.
2. **Generator opt-out.** Does `rails generate rspec:install --no-parallel`
   skip the comment block for users who'd rather not see it? Leaning no —
   commented-out is already zero friction.
3. **Threaded mode documentation.** Rails' `parallelize(with: :threads)`
   skips DB creation; if we ever support threads in rspec-core, the Rails
   integration docs need a "what breaks, what doesn't" section. Out of
   scope for this RFC.

## Timeline

rspec-rails work is small once rspec-core lands the runner — estimate
1–2 days of implementation + specs. This RFC tracks rspec-rails only; the
heavy lifting (master/worker protocol, DTO layer for notifications, CLI
flag, etc.) lives in the rspec-core RFC in the `rspec/rspec` repo.
