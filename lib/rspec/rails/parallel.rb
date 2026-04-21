module RSpec
  module Rails
    # Bridges rspec-core's parallel runner lifecycle with Rails' existing
    # parallel testing hooks (`ActiveSupport::Testing::Parallelization`).
    # Opt-in via `config.use_rails_parallel!` from `rails_helper.rb`; once
    # enabled, user code written against
    # `ActiveSupport::TestCase.parallelize_setup { |worker| ... }` executes
    # during RSpec's parallel runs exactly as it would under Minitest.
    #
    # Note: Rails' `Parallelization` exposes only `after_fork_hooks` and
    # `run_cleanup_hooks` -- there is no `before_fork_hooks` registry on
    # the Rails side. rspec-core's `parallelize_before_fork` is still
    # available to users directly via `RSpec.configure`; we just have
    # nothing to bridge it to.
    #
    # When rspec-core does not yet expose the parallel API, initialization
    # is a no-op. Require-order safe: works whether or not Rails is loaded.
    class ParallelConfiguration
      class << self
        def initialize_parallel_configuration(config)
          return unless parallel_api_available?(config)
          return unless initialized_configs.add?(config.object_id)

          ensure_active_record_hooks_loaded

          config.parallelize_setup do |worker_number|
            # Per-worker state first, so user hooks registered via
            # ActiveSupport::TestCase.parallelize_setup { |w| ... } see the
            # redirected logger and the per-worker Capybara port, not the
            # shared master state. ActiveRecord's TestDatabases hook (which
            # creates the per-worker DB) runs inside fire_after_fork_hooks;
            # any logging it emits therefore lands in the per-worker file.
            redirect_rails_logger(worker_number)
            assign_capybara_port(worker_number)
            fire_after_fork_hooks(worker_number)
          end

          config.parallelize_teardown do |worker_number|
            fire_cleanup_hooks(worker_number)
          end
        end

        # @api private
        # Used in specs to exercise re-initialization against a fresh config.
        def reset_initialized_configs!
          @initialized_configs = nil
        end

        def parallel_api_available?(config)
          config.respond_to?(:parallelize_setup) &&
            config.respond_to?(:parallelize_teardown)
        end

        def fire_after_fork_hooks(worker_number)
          return unless parallelization_defined?

          ::ActiveSupport::Testing::Parallelization.after_fork_hooks.each do |hook|
            hook.call(worker_number)
          end
        end

        def fire_cleanup_hooks(worker_number)
          return unless parallelization_defined?

          ::ActiveSupport::Testing::Parallelization.run_cleanup_hooks.each do |hook|
            hook.call(worker_number)
          end
        end

        # Capybara binds its test server to a single port (default 9000),
        # which collides across forked workers. Give each worker a 1000-port
        # band starting above the base, picking a random offset for
        # collision avoidance inside the band. Matches the convention used
        # by parallel_tests setups in production Rails apps.
        def assign_capybara_port(worker_number)
          return unless capybara_defined?

          ::Capybara.server_port = parallel_server_port_base + (worker_number * 1000) + rand(1..999)
        end

        # All workers inherit the master's `Rails.logger`, so without
        # intervention every worker appends to `log/test.log` and interleaves
        # output. Redirect each worker to its own `log/test-<worker>.log` so
        # users can `tail -f log/test-*.log` (or grep a specific worker)
        # during debugging. Rails' own Minitest integration doesn't ship this
        # hook -- users typically add it by hand in a `parallelize_setup`
        # block -- so we install it as part of `use_rails_parallel!`.
        def redirect_rails_logger(worker_number)
          return unless rails_logger_available?

          require "fileutils"
          log_path = ::Rails.root.join("log", "test-#{worker_number}.log")
          FileUtils.mkdir_p(File.dirname(log_path))
          new_logger = ::ActiveSupport::Logger.new(log_path)
          new_logger.formatter = ::Rails.logger.formatter if ::Rails.logger.respond_to?(:formatter)
          new_logger.level     = ::Rails.logger.level     if ::Rails.logger.respond_to?(:level)
          ::Rails.logger = ::ActiveSupport::TaggedLogging.new(new_logger)
        end

        private

        # Tracks config object_ids (not refs) to avoid pinning instances.
        def initialized_configs
          require "set"
          @initialized_configs ||= Set.new
        end

        def parallelization_defined?
          defined?(::ActiveSupport::Testing::Parallelization)
        end

        def capybara_defined?
          defined?(::Capybara)
        end

        def rails_logger_available?
          defined?(::Rails) &&
            ::Rails.respond_to?(:root) && ::Rails.root &&
            ::Rails.respond_to?(:logger) && ::Rails.logger &&
            defined?(::ActiveSupport::Logger) &&
            defined?(::ActiveSupport::TaggedLogging)
        end

        # Resilient against a Configuration instance that hasn't had
        # rspec-rails' initialize_configuration called on it (e.g. a fresh
        # RSpec::Core::Configuration.new in tests). 9000 matches the RFC
        # default and Capybara's own default port.
        def parallel_server_port_base
          if RSpec.configuration.respond_to?(:parallel_server_port_base)
            RSpec.configuration.parallel_server_port_base || 9000
          else
            9000
          end
        end

        # `ActiveRecord::TestDatabases` registers the hooks that create and
        # load per-worker test databases. It is autoloaded but only
        # *referenced* from `rails/test_help.rb`, which rspec-rails apps do
        # not require. Force the reference so the hooks register.
        #
        # Rails 8.1+ additionally gates those hooks on
        # `ActiveSupport.parallelize_test_databases` -- normally set to `true`
        # inside `ActiveSupport::TestCase.parallelize(...)`, which is the
        # Minitest entry point and never runs under rspec-rails. The default
        # is `true`, but app config or a stray assignment can disable it,
        # leaving every worker sharing the master's database. Set it
        # explicitly so opting into `use_rails_parallel!` is sufficient.
        def ensure_active_record_hooks_loaded
          return unless defined?(::ActiveRecord)

          require "active_record/test_databases"
          if ::ActiveSupport.respond_to?(:parallelize_test_databases=)
            ::ActiveSupport.parallelize_test_databases = true
          end
        rescue LoadError
          # Older Rails or unusual setups may not ship this file; the
          # integration still works for user-defined hooks, we just lose
          # automatic per-worker DB creation.
        end
      end
    end
  end
end

# Auto-wire the bridge on `require "rspec/rails"`. Installs the
# `parallelize_setup` / `parallelize_teardown` delegators against the
# current RSpec configuration so users don't need to call
# `config.use_rails_parallel!` themselves. When rspec-core hasn't shipped
# the parallel API yet, this is a no-op. When `--parallel` isn't in play,
# the hooks never fire. Users who want to disable the bridge can still
# keep their suite serial (`--no-parallel` or simply not setting
# `default_parallel_workers`). The public `use_rails_parallel!` method
# remains available and is idempotent -- it's a no-op on already-wired
# configs -- so older `rails_helper.rb` files that still call it
# continue to work unchanged.
RSpec::Rails::ParallelConfiguration.initialize_parallel_configuration(RSpec.configuration)
