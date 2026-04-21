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

ActiveSupport::TestCase.parallelize_before_fork do
  # pre-fork, master-side; drop pooled connections, etc.
end
```

Invocation matches Minitest parallel behavior:

```sh
bundle exec rspec                  # single-process (existing behavior)
bundle exec rspec --parallel 4     # 4 worker processes
bundle exec rspec --parallel       # :number_of_processors
PARALLEL_WORKERS=8 bundle exec rspec --parallel
```

Inside a spec, the current worker number (or `nil` outside parallel) is
readable via `RSpec.parallel_worker_number` (provided by rspec-core).

## Mechanism (rspec-rails)

A new file `lib/rspec/rails/parallel.rb`, required when `ActiveRecord` is
loaded, registers three delegating hooks against rspec-core's parallel
lifecycle:

```ruby
require "active_record/test_databases"  # force-load so AR's own hooks register

RSpec.configure do |c|
  c.parallelize_before_fork do
    ActiveSupport::Testing::Parallelization.before_fork_hooks.each(&:call)
  end
  c.parallelize_setup do |worker_number|
    ActiveSupport::Testing::Parallelization.after_fork_hooks.each { |h| h.call(worker_number) }
  end
  c.parallelize_teardown do |worker_number|
    ActiveSupport::Testing::Parallelization.run_cleanup_hooks.each { |h| h.call(worker_number) }
  end
end
```

The `require "active_record/test_databases"` is load-bearing. AR's module body
registers its own `before_fork_hook` / `after_fork_hook` that create and load
the per-worker schema (`<database>_<worker_number>`). Without forcing the
reference, Rails' `rails/test_help.rb` is the only loader — and rspec-rails
apps don't require it.

Once registered, the flow is:

1. **Master boots.** `rails_helper.rb` loads, triggers rspec-rails autoload,
   `lib/rspec/rails/parallel.rb` installs the three delegators on
   `RSpec.configuration`. `ActiveRecord::TestDatabases` module body runs,
   registering AR's own hooks on `ActiveSupport::Testing::Parallelization`.
2. **Pre-fork.** rspec-core's runner fires `parallelize_before_fork`. Our
   delegator calls AR's before-fork hook, which clears connection handlers.
3. **Fork N workers.** rspec-core forks. Each worker post-fork fires
   `parallelize_setup(worker_num)`. Our delegator iterates
   `after_fork_hooks`, which includes AR's DB create-and-load
   (`<database>_<worker_num>`) and any user-registered `parallelize_setup`
   block from `rails_helper.rb`.
4. **Workers run tests.** Each has its own DB, connection, worker number.
5. **Worker exit.** `parallelize_teardown(worker_num)` fires. Our delegator
   iterates `run_cleanup_hooks` including any user-registered teardown.

## What this does NOT include

- **System tests.** Capybara + headless browser per worker needs a unique
  port per worker. Doable but out of scope for v1 of this RFC; we'll ship
  documentation and add helpers in a follow-up.
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

## Open questions

1. **How strong a default?** Do we set `parallelize_test_databases = true`
   unconditionally when rspec-rails is loaded, or only when `--parallel` is
   requested? Leaning toward "only when requested" — no surprise behavior
   for existing suites.
2. **Generator template updates.** Should `rails generate rspec:install`
   write a commented-out `parallelize_setup` block in the new
   `rails_helper.rb`? Probably yes, once this ships.
3. **Per-worker log files.** Rails sets
   `Rails.logger = Logger.new("log/test-#{worker_num}.log")` via a default
   hook. Our delegation picks this up automatically via
   `after_fork_hooks`, but we should document that logs split across files
   when parallel.
4. **System test port allocation.** Design TBD. Likely a
   `RSpec.configuration.parallel_worker_number`-derived port offset for
   Capybara servers.

## Timeline

rspec-rails work is small once rspec-core lands the runner — estimate
1–2 days of implementation + specs. This RFC tracks rspec-rails only; the
heavy lifting (master/worker protocol, DTO layer for notifications, CLI
flag, etc.) lives in the rspec-core RFC in the `rspec/rspec` repo.
