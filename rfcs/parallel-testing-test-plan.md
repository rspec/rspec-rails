# Test plan: flesh out rspec-rails parallel integration specs

Status: ready for implementation
Parent RFC: [parallel-testing.md](parallel-testing.md)
Branch: `jakeonrails/issue-2104`

## Purpose

Current specs in `spec/rspec/rails/parallel_spec.rb` cover the happy path and unit-level contracts: delegator registration, hook fan-out with `worker_number`, Capybara port-band arithmetic, a real-fork end-to-end against rspec-core's `Parallel::Runner`. Research across `parallel_tests`, `turbo_tests`, `flatware`, and `rspecq` surfaced gaps worth closing before this ships. This plan enumerates them with enough detail that a fresh agent can implement.

## Context for the implementer

- **What we're building**: rspec-rails' bridge from rspec-core's parallel runner (`parallelize_setup` / `parallelize_teardown`) to Rails' `ActiveSupport::Testing::Parallelization.after_fork_hooks` / `run_cleanup_hooks`. Source: `lib/rspec/rails/parallel.rb`.
- **Runner lives in rspec-core**: fork-based master/worker model. The master forks N children; each child fires `parallelize_setup(worker_number)` post-fork, then runs its assigned example groups, then fires `parallelize_teardown(worker_number)` on exit. Our file bridges those two callbacks to Rails' hook registries.
- **rspec-core dependency**: path-sourced via `Gemfile-rspec-dependencies` → `../rspec/rspec-core` → sibling clone at `/Users/jakemoffatt/conductor/workspaces/rspec-rails/rspec/rspec-core` (branch `jakeonrails/parallel-rspec-chat`). That branch ships the parallel runner.
- **Running specs**: `bundle exec rspec spec/rspec/rails/parallel_spec.rb`. Full suite: `bundle exec rspec`. The existing real-fork block (`parallel_spec.rb:224`) has an `if:` guard that skips when rspec-core lacks `RSpec::Core::Parallel::Runner`, so it's safe on older rspec-core too.
- **Non-negotiables**:
  - Do not remove or weaken existing specs; only extend.
  - Do not introduce fixtures that require booting a full Rails app in-process during unit specs — the real-Rails e2e test (Item 1 below) is allowed to shell out.
  - Stubbing Capybara/ActiveSupport::Testing::Parallelization must continue to go through the predicate methods (`capybara_defined?`, `parallelization_defined?`) rather than `hide_const`, because `capybara/rspec` registers a global `after` hook that does a constant lookup on `Capybara` every example.
  - Avoid hard-coding rspec-core API details in assertions; prefer testing observable outcomes (hooks fire, DB exists, exit code correct) over implementation internals.

## What to add

Items tagged `[MUST]` must land before the PR; `[SHOULD]` before beta1 release; `[NICE]` can follow.

---

### [MUST] 1. Real-Rails fixture app end-to-end (single-DB)

**Why**: highest-signal test. Unit stubs cannot catch Rails-version regressions in `ActiveRecord::TestDatabases.create_and_load_schema`, nor changes to the `after_fork_hooks` registry name. `parallel_tests`' `spec/rails_spec.rb` is the canonical shape to mirror.

**Where**: new file `spec/rspec/rails/parallel_rails_integration_spec.rb`. Fixture app lives at `spec/support/fixtures/parallel_app/` (mirror the lightweight app style already used in rspec-rails generator specs).

**Fixture app shape** (minimum viable):

```
spec/support/fixtures/parallel_app/
├── Gemfile                           # rails, sqlite3, path-source rspec-rails + rspec-core
├── Rakefile
├── config/
│   ├── application.rb                # minimal ::Rails.application, load activerecord
│   ├── boot.rb
│   ├── database.yml                  # sqlite3, database: db/test.sqlite3
│   └── environments/test.rb
├── db/schema.rb                      # one table, e.g. `posts(:title)`
├── app/models/post.rb                # ApplicationRecord
└── spec/
    ├── spec_helper.rb
    ├── rails_helper.rb               # require parallel_app + rspec-rails
    └── models/post_spec.rb           # trivial: `expect(Post.count).to eq(0)`
```

**Test body (sketch)**:

```ruby
it "creates a per-worker SQLite database and both workers succeed" do
  Dir.chdir(app_path) do
    Bundler.with_unbundled_env do
      system!("bundle install --quiet")
      # run our parallel integration with 2 workers
      output = `bundle exec rspec --parallel 2 2>&1`
      expect($?.exitstatus).to eq(0)
      expect(Dir["db/test-*.sqlite3"].size).to eq(2)  # test-0, test-1
    end
  end
end
```

- Gate the whole `describe` with `if: Process.respond_to?(:fork) && ENV["RSPEC_RAILS_FULL_INTEGRATION"]` so CI opts in; default-skip keeps the core test run fast. Add a `rake parallel:rails` task (or just document the env var) so contributors can run it locally.
- The fixture app is committed (no generation at spec time); only the per-worker SQLite files are transient.

---

### [MUST] 2. Multi-DB per-worker verification

**Why**: Rails 6.1+ `connects_to` multi-DB is supported by `ActiveRecord::TestDatabases.create_and_load_schema` via `for_each_database` (`parallel_tests` invokes this at `lib/parallel_tests/tasks.rb:137-147` but has no dedicated spec — real gap). If the integration silently fails to create the secondary DB per worker, users lose test isolation without a loud error.

**Where**: either extend Item 1's fixture app with a `secondary` database, or add a pure-unit spec that stubs `ActiveRecord::Base.configurations.configs_for` to return two configs and asserts both run through the per-worker suffixing. Unit variant is cheaper and sufficient for regression coverage; skip the fixture-app overhead unless Item 1 is already in place.

**Unit-level assertions**:
1. When `ActiveRecord::TestDatabases.after_fork_hooks` is populated with AR's real hook, firing it with `worker_number: 1` calls `create_and_load_schema` for *each* configuration returned by `configs_for(env_name: "test")`.
2. The per-worker database name is `<base>_<worker_number>` (or `<base>-<worker_number>` depending on Rails version — check both).

Use `instance_double(ActiveRecord::DatabaseConfigurations)` + `allow(ActiveRecord::Base).to receive(:configurations).and_return(...)`.

---

### [MUST] 3. First-file-raises-at-load / non-example error survives worker lifecycle

**Why**: a spec file that raises at `require` time (LoadError, syntax error, Rails initializer exploding) must not hang the master or silently kill the worker. `turbo_tests` tests this at `spec/cli_spec.rb:35-43` with fixture `fixtures/rspec/errors_outside_of_examples_spec.rb`. Our current real-fork spec (`parallel_spec.rb:252`) uses groups that can't raise at load — add a sibling group that does.

**Where**: extend the existing `describe "real-fork run with Parallel::Runner"` block in `parallel_spec.rb`.

**Test body (sketch)**:

```ruby
it "reports a non-zero exit when a worker's example group raises at describe-time" do
  with_isolated_rspec_state do
    config = build_quiet_configuration
    world  = RSpec::Core::World.new(config)
    RSpec.instance_variable_set(:@configuration, config)
    RSpec.instance_variable_set(:@world, world)

    # One group that raises at load time (simulating a bad spec file).
    bad_group  = RSpec::Core::ExampleGroup.describe("boom") { raise "top-level boom" }
    good_group = RSpec::Core::ExampleGroup.describe("ok")   { it("a") {} }
    [bad_group, good_group].each { |g| world.record(g) }
    world.instance_variable_set(:@example_groups_and_filters_loaded, true)

    runner = RSpec::Core::Parallel::Runner.new(config, world, 2)
    exit_code = runner.run_specs([bad_group, good_group])

    expect(exit_code).not_to eq(0)
  end
end
```

If `ExampleGroup.describe { raise }` doesn't actually raise at describe-time in rspec-core's current model, use a group that raises in `before(:all)` instead — same contract from the parallel-runner's perspective.

**Note for implementer**: this is as much a rspec-core concern as ours. If rspec-core already has equivalent coverage in its own suite, a pointer comment in our spec is sufficient and no new test is needed. Check `../rspec/rspec-core/spec/rspec/core/parallel/runner_spec.rb` first.

---

### [MUST] 5. Idempotent hook registration

**Why**: if a user requires `rails/test_help` in `rails_helper.rb` AND rspec-rails calls `ensure_active_record_hooks_loaded`, `ActiveRecord::TestDatabases`' module body runs twice only if Ruby re-evaluates it (it shouldn't — `require` is idempotent) — but if someone does `load "active_record/test_databases"`, or if a future rspec-rails change uses `load` instead of `require`, duplicate hooks would fire and attempt to create the per-worker schema twice per worker. Assert the contract so we catch a regression.

**Where**: new spec in `parallel_spec.rb`.

**Test body (sketch)**:

```ruby
describe "hook registration is idempotent" do
  it "calling initialize_parallel_configuration twice does not double-fire hooks" do
    fake_config = build_fake_parallel_config
    described_class.initialize_parallel_configuration(fake_config)
    described_class.initialize_parallel_configuration(fake_config)

    call_log = []
    stub_parallelization_with_hook { |n| call_log << n }
    fake_config.setup_block.call(42)

    # Regardless of how many times we initialized, each firing runs each hook
    # exactly once per call.
    expect(call_log).to eq([42])
  end
end
```

Note: the meaningful assertion here is that `ensure_active_record_hooks_loaded` is a no-op on second call (standard `require` behavior) AND that calling `initialize_parallel_configuration` twice doesn't register duplicate delegators on `config`. The latter depends on whether rspec-core's `parallelize_setup` appends or replaces — test observable behavior, not internals.

---

### [MUST] 6. `parallelize_teardown` runs even when example group raised

**Why**: Capybara's Selenium driver relies on its `at_exit` hook (which we already force via the rspec-core `exit!` → `exit` fix); Rails' per-worker cleanup hooks rely on `run_cleanup_hooks` firing regardless of example outcome. If a group blows up mid-run, workers must still fire teardown, or we leak DB connections / browser sessions. `flatware`'s `worker_spec.rb:38-48` codifies this contract.

**Where**: extend the real-fork `describe` block.

**Test body (sketch)**:

```ruby
it "fires cleanup hooks even when a worker's example fails" do
  cleanup_log = Tempfile.new("cleanup-log")
  fake_parallelization = Module.new
  fake_parallelization.define_singleton_method(:after_fork_hooks) { [] }
  fake_parallelization.define_singleton_method(:run_cleanup_hooks) do
    [proc { |n| File.open(cleanup_log.path, "a") { |f| f.puts "cleanup:#{n}" } }]
  end
  stub_const("ActiveSupport::Testing::Parallelization", fake_parallelization)

  with_isolated_rspec_state do
    # ... build config/world ...
    failing = RSpec::Core::ExampleGroup.describe("fail") { it("bad") { raise "nope" } }
    world.record(failing)
    runner = RSpec::Core::Parallel::Runner.new(config, world, 1)
    runner.run_specs([failing])
  end

  expect(File.read(cleanup_log.path)).to match(/cleanup:0/)
ensure
  cleanup_log&.close
  cleanup_log&.unlink
end
```

---

### [SHOULD] 7. Rails hook fires before user `parallelize_setup`

**Why**: ordering contract. Rails' AR `after_fork_hook` creates the per-worker DB; user code in `rails_helper.rb` (e.g. seeding fixtures, setting up Redis namespaces) assumes a live connection. If user hooks run first, they crash on a non-existent DB. Easy to break if rspec-core's `parallelize_setup` block registration order changes, or if rspec-rails' file load order shifts.

**Where**: extend the `describe "integration with real RSpec::Core::Configuration"` block (already gated by `parallel_api_available?`).

**Test body (sketch)**:

```ruby
it "fires Rails after_fork_hooks before any user-registered parallelize_setup block" do
  call_log = []
  fake_parallelization.define_singleton_method(:after_fork_hooks) do
    [proc { |n| call_log << [:rails, n] }]
  end
  fake_parallelization.define_singleton_method(:run_cleanup_hooks) { [] }

  described_class.initialize_parallel_configuration(real_config)
  real_config.parallelize_setup { |n| call_log << [:user, n] }
  real_config.fire_parallelize_setup_hooks(0)

  expect(call_log).to eq([[:rails, 0], [:user, 0]])
end
```

If the order reverses in practice, the fix is on our side: swap the `parallelize_setup` registration to run before user hooks are registered. Investigate rspec-core's `fire_parallelize_setup_hooks` to confirm it iterates in registration order (I believe it does — confirm by reading `../rspec/rspec-core/lib/rspec/core/configuration.rb`).

---

### [SHOULD] 8. Real-fork Capybara port test (two workers bind real TCP servers, no collision)

**Why**: current Capybara specs test only the arithmetic of the port-band assignment. They don't prove that two workers actually *can* bind their chosen ports simultaneously without collision. The real-fork harness at `parallel_spec.rb:224` is the right scaffolding to extend.

**Where**: new test in the real-fork `describe` block.

**Test body (sketch)**:

```ruby
it "two workers assigned distinct Capybara ports can each bind a TCP server" do
  # Require capybara here (or guard with `if defined?(Capybara)`) — don't
  # add it as a hard test dependency unless it's already one.
  skip "capybara not loaded" unless defined?(::Capybara)

  # Set up two workers, each one writes:
  #   "worker:#{n}:port:#{Capybara.server_port}" to a shared log
  # and then briefly opens a TCPServer on that port to prove it's available.
  # Master asserts:
  #   - two distinct ports were chosen
  #   - both in the expected band (9001-9999, 10001-10999)
  #   - neither port is the literal base (9000)
end
```

Use a short timeout + release the TCPServer before returning from the hook.

---

### [NICE] 9. Worker isolation of globals

**Why**: rspecq's `$tries` fixture pattern adapted — prove that a global variable mutated in worker 0 doesn't leak to worker 1. Fork semantics guarantee this, but regressions are possible if rspec-core ever introduces a worker pool with shared state (unlikely but cheap to lock down).

**Where**: real-fork `describe` block.

**Test body (sketch)**: worker N sets `$worker_N_saw` and writes its full `$` symbol table to a log file; master reads logs and asserts neither worker saw the other's global.

---

### [NICE] 10. Fixture-load-per-worker assertion

**Why**: Rails fixtures under parallel should load once per worker (once the per-worker DB is created), not once per example. If rspec-rails' `FixtureSupport` ever gets touched in ways that interact with parallel, this locks in the expected behavior.

**Where**: add to Item 1's fixture app — add a `spec/fixtures/posts.yml`, assert a counter instrumented via `ActiveRecord::FixtureSet` shows one load per worker.

## Items explicitly out of scope for this plan

- **Exit-status propagation** (turbo_tests' fix at `runner.rb:100-105`): belongs in rspec-core's `Parallel::Runner` spec, not ours. Peer (rspec-core side) has been notified and is aware.
- **Worker-crash requeue, exception marshalling, fail-fast, SIGINT/SIGCHLD, messages-from-dead-worker race, seed reproducibility**: all rspec-core concerns. Peer has triaged and is taking the top two pre-beta1.
- **Threaded parallel mode**: not supported in v1 per the RFC.
- **Windows**: no `fork`; rspec-core may add a shell-based fallback post-v1.
- **Advanced headless-browser isolation** (per-worker Chrome user-data dirs, remote-driver session isolation): follow-up work per the RFC.

## Suggested implementation order

1. Item 5 (idempotent) — fastest, pure unit, shakes out the pattern.
2. Item 6 (teardown on failure) — extends existing real-fork harness, high safety value.
3. Item 7 (hook ordering) — extends existing integration-with-real-config block.
4. Item 8 (real TCP Capybara port test) — extends real-fork harness.
5. Item 3 (first-file-raises) — may reveal that rspec-core already covers it and we skip.
6. Item 2 (multi-DB unit variant) — pure unit, fast.
7. Item 1 (Rails fixture app E2E) — largest. Do last; most infrastructure.
8. Items 9 & 10 — only if time permits before PR.

## Handoff notes

- Keep each new `it` block under ~25 lines; prefer many small specs over one compound spec.
- Use `let` + shared setup helpers (`build_quiet_configuration`, `with_isolated_rspec_state`) that already exist at `parallel_spec.rb:234-250`.
- When adding any `stub_const("ActiveSupport::Testing::Parallelization", ...)`, always `.define_singleton_method(:after_fork_hooks)` AND `:run_cleanup_hooks` so accidental calls into the other registry don't raise NoMethodError.
- Before adding a new top-level `describe`, check if the assertion fits inside the existing `describe "real-fork run with Parallel::Runner"` — most do.
- After each new spec lands, run: `bundle exec rspec spec/rspec/rails/parallel_spec.rb` and the full suite. User prefers specs written and run continuously, not as a cleanup pass.
- When finished, leave all work uncommitted on `jakeonrails/issue-2104` — user drives the commit + PR timing.
