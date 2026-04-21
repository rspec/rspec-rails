require "rspec/rails/parallel"

begin
  require "rspec/core/parallel/runner"
rescue LoadError
  # rspec-core without the parallel runner -- the real-fork describe block below
  # is :if-guarded to skip in that case.
end

RSpec.describe RSpec::Rails::ParallelConfiguration do
  let(:fake_config) { instance_double("RSpec::Core::Configuration") }

  describe ".parallel_api_available?" do
    it "is true when config responds to both parallelize_setup and parallelize_teardown" do
      allow(fake_config).to receive(:respond_to?).with(:parallelize_setup).and_return(true)
      allow(fake_config).to receive(:respond_to?).with(:parallelize_teardown).and_return(true)
      expect(described_class.parallel_api_available?(fake_config)).to be true
    end

    it "is false when teardown is missing" do
      allow(fake_config).to receive(:respond_to?).with(:parallelize_setup).and_return(true)
      allow(fake_config).to receive(:respond_to?).with(:parallelize_teardown).and_return(false)
      expect(described_class.parallel_api_available?(fake_config)).to be false
    end

    it "is false when none are present (pre-parallel rspec-core)" do
      allow(fake_config).to receive(:respond_to?).with(:parallelize_setup).and_return(false)
      allow(fake_config).to receive(:respond_to?).with(:parallelize_teardown).and_return(false)
      expect(described_class.parallel_api_available?(fake_config)).to be false
    end
  end

  describe ".initialize_parallel_configuration" do
    context "when rspec-core lacks the parallel API" do
      it "is a silent no-op" do
        allow(described_class).to receive(:parallel_api_available?).and_return(false)
        expect { described_class.initialize_parallel_configuration(fake_config) }.not_to raise_error
      end
    end

    context "when rspec-core exposes the parallel API" do
      let(:fake_parallel_config) do
        Class.new do
          attr_reader :setup_block, :teardown_block

          def parallelize_setup(&blk) = @setup_block = blk
          def parallelize_teardown(&blk) = @teardown_block = blk
        end.new
      end

      before do
        allow(described_class).to receive(:ensure_active_record_hooks_loaded)
      end

      it "registers blocks for both lifecycle points" do
        described_class.initialize_parallel_configuration(fake_parallel_config)

        expect(fake_parallel_config.setup_block).to be_a(Proc)
        expect(fake_parallel_config.teardown_block).to be_a(Proc)
      end

      it "the setup block fans out with the worker number" do
        described_class.initialize_parallel_configuration(fake_parallel_config)
        expect(described_class).to receive(:fire_after_fork_hooks).with(3)
        fake_parallel_config.setup_block.call(3)
      end

      # User code registered via `ActiveSupport::TestCase.parallelize_setup`
      # fans out through `fire_after_fork_hooks`. The per-worker logger and
      # Capybara port therefore must be assigned *before* those hooks run, or
      # user hooks observe the shared master-process state the branch
      # advertises away.
      it "assigns per-worker state before firing user after_fork_hooks" do
        described_class.initialize_parallel_configuration(fake_parallel_config)

        call_order = []
        allow(described_class).to receive(:redirect_rails_logger) { call_order << :logger }
        allow(described_class).to receive(:assign_capybara_port) { call_order << :port }
        allow(described_class).to receive(:fire_after_fork_hooks) { call_order << :user_hooks }

        fake_parallel_config.setup_block.call(0)

        expect(call_order.last).to eq(:user_hooks)
        expect(call_order).to include(:logger, :port)
      end

      it "the teardown block fans out with the worker number" do
        described_class.initialize_parallel_configuration(fake_parallel_config)
        expect(described_class).to receive(:fire_cleanup_hooks).with(7)
        fake_parallel_config.teardown_block.call(7)
      end

      it "forces ActiveRecord hook registration" do
        expect(described_class).to receive(:ensure_active_record_hooks_loaded)
        described_class.initialize_parallel_configuration(fake_parallel_config)
      end
    end
  end

  describe "hook registration is idempotent",
           if: RSpec::Rails::ParallelConfiguration.parallel_api_available?(RSpec::Core::Configuration.new) do
    let(:real_config) { RSpec::Core::Configuration.new }
    let(:fake_parallelization) { Module.new }

    before do
      described_class.reset_initialized_configs!
      stub_const("ActiveSupport::Testing::Parallelization", fake_parallelization)
      allow(described_class).to receive(:ensure_active_record_hooks_loaded)
    end

    after { described_class.reset_initialized_configs! }

    it "calling initialize_parallel_configuration twice does not double-fire rails hooks" do
      call_log = []
      fake_parallelization.define_singleton_method(:after_fork_hooks) do
        [proc { |n| call_log << [:rails, n] }]
      end
      fake_parallelization.define_singleton_method(:run_cleanup_hooks) { [] }

      described_class.initialize_parallel_configuration(real_config)
      described_class.initialize_parallel_configuration(real_config)
      real_config.fire_parallelize_setup_hooks(42)

      expect(call_log).to eq([[:rails, 42]])
    end

    it "does not register duplicate teardown delegators on repeat initialization" do
      call_log = []
      fake_parallelization.define_singleton_method(:after_fork_hooks) { [] }
      fake_parallelization.define_singleton_method(:run_cleanup_hooks) do
        [proc { |n| call_log << [:cleanup, n] }]
      end

      described_class.initialize_parallel_configuration(real_config)
      described_class.initialize_parallel_configuration(real_config)
      real_config.fire_parallelize_teardown_hooks(5)

      expect(call_log).to eq([[:cleanup, 5]])
    end

    it "does not re-require active_record/test_databases on repeat initialization" do
      expect(described_class).to receive(:ensure_active_record_hooks_loaded).once
      described_class.initialize_parallel_configuration(real_config)
      described_class.initialize_parallel_configuration(real_config)
    end
  end

  describe "hook fan-out" do
    let(:fake_parallelization) { Module.new }

    before do
      # Simulate ActiveSupport::Testing::Parallelization being loaded without
      # actually requiring Rails (keeps this spec isolated). We stub the
      # constant lookup used inside ParallelConfiguration.
      stub_const("ActiveSupport::Testing::Parallelization", fake_parallelization)
    end

    describe ".fire_after_fork_hooks" do
      it "invokes each registered after_fork_hook with the worker number" do
        call_log = []
        fake_parallelization.define_singleton_method(:after_fork_hooks) do
          [proc { |n| call_log << [:a, n] }, proc { |n| call_log << [:b, n] }]
        end

        described_class.fire_after_fork_hooks(3)

        expect(call_log).to eq([[:a, 3], [:b, 3]])
      end

      it "is a no-op when Parallelization is not defined" do
        hide_const("ActiveSupport::Testing::Parallelization")
        expect { described_class.fire_after_fork_hooks(0) }.not_to raise_error
      end
    end

    describe ".fire_cleanup_hooks" do
      it "invokes each registered run_cleanup_hook with the worker number" do
        call_log = []
        fake_parallelization.define_singleton_method(:run_cleanup_hooks) do
          [proc { |n| call_log << [:cleanup, n] }]
        end

        described_class.fire_cleanup_hooks(7)

        expect(call_log).to eq([[:cleanup, 7]])
      end

      it "is a no-op when Parallelization is not defined" do
        hide_const("ActiveSupport::Testing::Parallelization")
        expect { described_class.fire_cleanup_hooks(0) }.not_to raise_error
      end
    end
  end

  describe ".assign_capybara_port" do
    context "when Capybara is not loaded" do
      before { allow(described_class).to receive(:capybara_defined?).and_return(false) }

      it "is a silent no-op (does not touch Capybara)" do
        # We don't even try to look up the Capybara constant, since rspec-rails
        # apps without system/feature specs may not have it loaded at all.
        expect(::Capybara).not_to receive(:server_port=)
        expect { described_class.assign_capybara_port(0) }.not_to raise_error
      end
    end

    context "when Capybara is loaded" do
      let(:original_port) { ::Capybara.server_port }
      after { ::Capybara.server_port = original_port }

      it "puts worker 0 in the 9001-9999 band by default" do
        described_class.assign_capybara_port(0)
        expect(::Capybara.server_port).to be_between(9001, 9999)
      end

      it "puts worker N in a band 1000 above worker N-1" do
        described_class.assign_capybara_port(0)
        worker0 = ::Capybara.server_port
        described_class.assign_capybara_port(1)
        worker1 = ::Capybara.server_port

        expect(worker1).to be_between(10_001, 10_999)
        expect(worker1 - worker0).to be_between(2, 1998)
      end

      it "honors RSpec.configuration.parallel_server_port_base" do
        allow(RSpec.configuration).to receive(:parallel_server_port_base).and_return(20_000)
        described_class.assign_capybara_port(2)
        expect(::Capybara.server_port).to be_between(22_001, 22_999)
      end

      it "never picks the literal base port (so the user's default stays free)" do
        100.times do
          described_class.assign_capybara_port(0)
          expect(::Capybara.server_port).not_to eq(9000)
        end
      end
    end
  end

  describe ".redirect_rails_logger" do
    context "when Rails is not loaded" do
      before { allow(described_class).to receive(:rails_logger_available?).and_return(false) }

      it "is a silent no-op" do
        expect { described_class.send(:redirect_rails_logger, 0) }.not_to raise_error
      end
    end

    context "when Rails is loaded" do
      let(:tmpdir) { Dir.mktmpdir("rspec-rails-parallel-log-") }
      let(:rails_double) { double("Rails", root: Pathname.new(tmpdir), logger: original_logger) }
      let(:original_logger) do
        ActiveSupport::TaggedLogging.new(
          ActiveSupport::Logger.new(File::NULL).tap do |l|
            l.level = ::Logger::WARN
            l.formatter = ->(_, _, _, msg) { "fmt:#{msg}\n" }
          end
        )
      end

      before do
        stub_const("Rails", rails_double)
        allow(rails_double).to receive(:logger=) { |new| allow(rails_double).to receive(:logger).and_return(new) }
      end

      after { FileUtils.remove_entry(tmpdir) }

      it "writes the worker's log to log/test-<worker>.log under Rails.root" do
        described_class.send(:redirect_rails_logger, 3)
        ::Rails.logger.warn("hello from worker 3")
        ::Rails.logger.close if ::Rails.logger.respond_to?(:close)

        expected = File.join(tmpdir, "log", "test-3.log")
        expect(File.exist?(expected)).to be true
        expect(File.read(expected)).to include("hello from worker 3")
      end

      it "creates log/ under Rails.root if it does not already exist" do
        expect(Dir.exist?(File.join(tmpdir, "log"))).to be false
        described_class.send(:redirect_rails_logger, 0)
        expect(Dir.exist?(File.join(tmpdir, "log"))).to be true
      end

      it "preserves the formatter and level from the previous logger" do
        described_class.send(:redirect_rails_logger, 1)
        # TaggedLogging wraps, so reach through to the wrapped logger:
        wrapped = ::Rails.logger.instance_variable_get(:@logger) || ::Rails.logger
        expect(wrapped.level).to eq(::Logger::WARN)
        expect(wrapped.formatter.call(nil, nil, nil, "x")).to eq("fmt:x\n")
      end
    end
  end

  # Round-trip against the real rspec-core parallel API (only present on
  # rspec-core versions that ship the parallel runner — the
  # parallel_api_available? guard makes this section a no-op otherwise).
  describe "integration with real RSpec::Core::Configuration",
           if: RSpec::Rails::ParallelConfiguration.parallel_api_available?(RSpec::Core::Configuration.new) do
    let(:real_config) { RSpec::Core::Configuration.new }
    let(:fake_parallelization) { Module.new }

    before do
      stub_const("ActiveSupport::Testing::Parallelization", fake_parallelization)
      allow(described_class).to receive(:ensure_active_record_hooks_loaded)
    end

    it "fires registered setup hooks with the worker number via the real config surface" do
      call_log = []
      fake_parallelization.define_singleton_method(:after_fork_hooks) { [proc { |n| call_log << [:setup, n] }] }

      described_class.initialize_parallel_configuration(real_config)
      real_config.fire_parallelize_setup_hooks(2)

      expect(call_log).to eq([[:setup, 2]])
    end

    it "fires registered teardown hooks with the worker number via the real config surface" do
      call_log = []
      fake_parallelization.define_singleton_method(:run_cleanup_hooks) { [proc { |n| call_log << [:teardown, n] }] }

      described_class.initialize_parallel_configuration(real_config)
      real_config.fire_parallelize_teardown_hooks(4)

      expect(call_log).to eq([[:teardown, 4]])
    end

    it "accumulates with user-registered parallelize_setup blocks (does not stomp)" do
      call_log = []
      fake_parallelization.define_singleton_method(:after_fork_hooks) { [proc { |n| call_log << [:rails_hook, n] }] }

      described_class.initialize_parallel_configuration(real_config)
      real_config.parallelize_setup { |n| call_log << [:user_hook, n] }
      real_config.fire_parallelize_setup_hooks(1)

      expect(call_log).to contain_exactly([:rails_hook, 1], [:user_hook, 1])
    end

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

    it "fires Rails run_cleanup_hooks before any user-registered parallelize_teardown block" do
      call_log = []
      fake_parallelization.define_singleton_method(:run_cleanup_hooks) do
        [proc { |n| call_log << [:rails, n] }]
      end

      described_class.initialize_parallel_configuration(real_config)
      real_config.parallelize_teardown { |n| call_log << [:user, n] }
      real_config.fire_parallelize_teardown_hooks(0)

      expect(call_log).to eq([[:rails, 0], [:user, 0]])
    end
  end

  describe ".ensure_active_record_hooks_loaded",
           if: defined?(::ActiveRecord) do
    # Rails 8.1+ gates ActiveRecord::TestDatabases' after_fork_hook on
    # `ActiveSupport.parallelize_test_databases` (default true). App
    # config or a stray assignment can disable it, and we never call
    # `ActiveSupport::TestCase.parallelize`, the Minitest entry point
    # that normally re-asserts it. Flip it on here so opting into
    # `use_rails_parallel!` is sufficient. Rails 8.0 and earlier don't
    # expose the accessor; the hook fires unconditionally and there's
    # nothing to set.
    it "flips ActiveSupport.parallelize_test_databases on when the accessor exists" do
      captured = []
      ::ActiveSupport.singleton_class.send(:define_method, :parallelize_test_databases=) { |v| captured << v }
      begin
        described_class.send(:ensure_active_record_hooks_loaded)
        expect(captured).to eq([true])
      ensure
        ::ActiveSupport.singleton_class.send(:remove_method, :parallelize_test_databases=)
      end
    end

    it "does nothing when ActiveSupport does not expose the accessor" do
      allow(::ActiveSupport).to receive(:respond_to?).and_call_original
      allow(::ActiveSupport).to receive(:respond_to?).with(:parallelize_test_databases=).and_return(false)
      expect { described_class.send(:ensure_active_record_hooks_loaded) }.not_to raise_error
    end
  end

  # Locks in the contract we rely on from ActiveRecord::TestDatabases: when
  # fired with a worker_number, its create_and_load_schema iterates over every
  # configuration returned by `configs_for(env_name: ...)` and suffixes the
  # database name per worker. If Rails ever changes shape here, our
  # per-worker multi-DB behavior would silently regress.
  describe "ActiveRecord multi-database per-worker suffixing",
           if: defined?(::ActiveRecord) do
    before { require "active_record/test_databases" }

    let(:primary)   { double("HashConfig-primary",   database: "app_test") }
    let(:secondary) { double("HashConfig-secondary", database: "app_analytics_test") }
    let(:configs)   { instance_double("ActiveRecord::DatabaseConfigurations") }

    before do
      [primary, secondary].each { |c| allow(c).to receive(:_database=) }
      allow(configs).to receive(:configs_for).with(env_name: "test").and_return([primary, secondary])
      allow(ActiveRecord::Base).to receive(:configurations).and_return(configs)
      allow(ActiveRecord::Base).to receive(:establish_connection)
      allow(ActiveRecord::Tasks::DatabaseTasks).to receive(:reconstruct_from_schema)
    end

    it "suffixes each configured database with the worker number" do
      ActiveRecord::TestDatabases.create_and_load_schema(1, env_name: "test")

      expect(primary).to have_received(:_database=).with(a_string_matching(/app_test[-_]1/))
      expect(secondary).to have_received(:_database=).with(a_string_matching(/app_analytics_test[-_]1/))
    end

    it "reconstructs the schema for every configured database" do
      ActiveRecord::TestDatabases.create_and_load_schema(2, env_name: "test")

      expect(ActiveRecord::Tasks::DatabaseTasks).to have_received(:reconstruct_from_schema).with(primary, nil)
      expect(ActiveRecord::Tasks::DatabaseTasks).to have_received(:reconstruct_from_schema).with(secondary, nil)
    end
  end

  # Real-fork end-to-end: drive rspec-core's Parallel::Runner with two
  # workers, with a Rails-style after_fork_hook registered. Each worker
  # writes a file from inside its parallelize_setup callback; the master
  # asserts the files exist with the right worker_number. Skipped on
  # platforms without fork() and on rspec-core versions without the
  # parallel runner.
  describe "real-fork run with Parallel::Runner",
           if: Process.respond_to?(:fork) && defined?(RSpec::Core::Parallel::Runner) do
    require 'tmpdir'
    require 'fileutils'
    require 'timeout'

    let(:tmpdir)    { Dir.mktmpdir("rspec-rails-parallel") }
    let(:setup_log) { File.join(tmpdir, "setup.log") }

    after { FileUtils.rm_rf(tmpdir) }

    def with_isolated_rspec_state
      saved_config = RSpec.configuration
      saved_world  = RSpec.instance_variable_get(:@world)
      yield
    ensure
      RSpec.instance_variable_set(:@configuration, saved_config)
      RSpec.instance_variable_set(:@world, saved_world)
    end

    def build_quiet_configuration
      config = RSpec::Core::Configuration.new
      config.output_stream = StringIO.new
      config.error_stream  = StringIO.new
      config.color_mode    = :off
      config.formatter     = 'progress'
      config
    end

    it "fires Rails-registered after_fork_hooks inside each worker with the right worker_number" do
      log = setup_log
      fake_parallelization = Module.new
      fake_parallelization.define_singleton_method(:after_fork_hooks) do
        [proc { |n| File.open(log, "a") { |f| f.puts "rails-hook:worker:#{n}:#{Process.pid}" } }]
      end
      fake_parallelization.define_singleton_method(:run_cleanup_hooks) { [] }
      stub_const("ActiveSupport::Testing::Parallelization", fake_parallelization)

      with_isolated_rspec_state do
        config = build_quiet_configuration
        world  = RSpec::Core::World.new(config)
        RSpec.instance_variable_set(:@configuration, config)
        RSpec.instance_variable_set(:@world, world)

        allow(described_class).to receive(:ensure_active_record_hooks_loaded)
        described_class.reset_initialized_configs!
        described_class.initialize_parallel_configuration(config)

        group_a = RSpec::Core::ExampleGroup.describe("A") { it("a") {} }
        group_b = RSpec::Core::ExampleGroup.describe("B") { it("b") {} }
        [group_a, group_b].each { |g| world.record(g) }
        world.instance_variable_set(:@example_groups_and_filters_loaded, true)

        runner = RSpec::Core::Parallel::Runner.new(config, world, 2)
        exit_code = runner.run_specs([group_a, group_b])

        expect(exit_code).to eq(0)

        lines = File.readlines(setup_log)
        expect(lines.size).to eq(2)
        expect(lines.map { |l| l[/worker:(\d)/, 1] }.sort).to eq(%w[0 1])
      end
    end

    it "lets two workers assigned distinct Capybara ports each bind a TCP server" do
      skip "capybara not loaded" unless defined?(::Capybara)
      require "socket"

      log = File.join(tmpdir, "ports.log")
      fake_parallelization = Module.new
      fake_parallelization.define_singleton_method(:after_fork_hooks) { [] }
      fake_parallelization.define_singleton_method(:run_cleanup_hooks) { [] }
      stub_const("ActiveSupport::Testing::Parallelization", fake_parallelization)

      with_isolated_rspec_state do
        config = build_quiet_configuration
        world  = RSpec::Core::World.new(config)
        RSpec.instance_variable_set(:@configuration, config)
        RSpec.instance_variable_set(:@world, world)

        allow(described_class).to receive(:ensure_active_record_hooks_loaded)
        described_class.reset_initialized_configs!
        described_class.initialize_parallel_configuration(config)

        config.parallelize_setup do |n|
          port = ::Capybara.server_port
          begin
            server = TCPServer.new("127.0.0.1", port)
            server.close
          rescue Errno::EADDRINUSE
            # Random port inside the band happened to be in use on the
            # host; the rspec-rails assignment still succeeded, which is
            # what this spec cares about. Log the port unconditionally.
          end
          File.open(log, "a") { |f| f.puts "worker:#{n}:port:#{port}" }
        end

        group_a = RSpec::Core::ExampleGroup.describe("A") { it("a") {} }
        group_b = RSpec::Core::ExampleGroup.describe("B") { it("b") {} }
        [group_a, group_b].each { |g| world.record(g) }
        world.instance_variable_set(:@example_groups_and_filters_loaded, true)

        runner = RSpec::Core::Parallel::Runner.new(config, world, 2)
        exit_code = runner.run_specs([group_a, group_b])

        expect(exit_code).to eq(0)

        lines = File.readlines(log).map(&:strip)
        expect(lines.size).to eq(2)

        ports_by_worker = lines.each_with_object({}) do |line, acc|
          acc[line[/worker:(\d)/, 1]] = line[/port:(\d+)/, 1].to_i
        end

        expect(ports_by_worker.values.uniq.size).to eq(2)
        expect(ports_by_worker["0"]).to be_between(9001, 9999)
        expect(ports_by_worker["1"]).to be_between(10_001, 10_999)
      end
    end

    it "fires parallelize_teardown hooks even when a worker's example fails" do
      log = File.join(tmpdir, "cleanup.log")
      fake_parallelization = Module.new
      fake_parallelization.define_singleton_method(:after_fork_hooks) { [] }
      fake_parallelization.define_singleton_method(:run_cleanup_hooks) do
        [proc { |n| File.open(log, "a") { |f| f.puts "cleanup:#{n}" } }]
      end
      stub_const("ActiveSupport::Testing::Parallelization", fake_parallelization)

      with_isolated_rspec_state do
        config = build_quiet_configuration
        world  = RSpec::Core::World.new(config)
        RSpec.instance_variable_set(:@configuration, config)
        RSpec.instance_variable_set(:@world, world)

        allow(described_class).to receive(:ensure_active_record_hooks_loaded)
        described_class.reset_initialized_configs!
        described_class.initialize_parallel_configuration(config)

        failing = RSpec::Core::ExampleGroup.describe("boom") { it("fails") { raise "nope" } }
        world.record(failing)
        world.instance_variable_set(:@example_groups_and_filters_loaded, true)

        runner = RSpec::Core::Parallel::Runner.new(config, world, 1)
        exit_code = runner.run_specs([failing])

        expect(exit_code).not_to eq(0)
        expect(File.read(log)).to match(/cleanup:0/)
      end
    end

    it "returns non-zero exit when a worker's example group raises in before(:all)" do
      fake_parallelization = Module.new
      fake_parallelization.define_singleton_method(:after_fork_hooks) { [] }
      fake_parallelization.define_singleton_method(:run_cleanup_hooks) { [] }
      stub_const("ActiveSupport::Testing::Parallelization", fake_parallelization)

      with_isolated_rspec_state do
        config = build_quiet_configuration
        world  = RSpec::Core::World.new(config)
        RSpec.instance_variable_set(:@configuration, config)
        RSpec.instance_variable_set(:@world, world)

        allow(described_class).to receive(:ensure_active_record_hooks_loaded)
        described_class.reset_initialized_configs!
        described_class.initialize_parallel_configuration(config)

        boom = RSpec::Core::ExampleGroup.describe("boom") do
          before(:all) { raise "top-level boom" }
          it("is never reached") {}
        end
        okay = RSpec::Core::ExampleGroup.describe("okay") { it("passes") {} }
        [boom, okay].each { |g| world.record(g) }
        world.instance_variable_set(:@example_groups_and_filters_loaded, true)

        runner = RSpec::Core::Parallel::Runner.new(config, world, 2)
        exit_code = Timeout.timeout(30) { runner.run_specs([boom, okay]) }

        expect(exit_code).not_to eq(0)
      end
    end
  end
end
