module RSpec::Rails
  RSpec.describe RailsExampleGroup, :with_isolated_config do
    it 'supports tagged_logger' do
      expect(described_class.private_instance_methods).to include(:tagged_logger)
    end

    it 'does not leak context between example groups' do
      groups =
        [
          RSpec::Core::ExampleGroup.describe("A group") do
            include RSpec::Rails::RailsExampleGroup
            specify { expect(ActiveSupport::ExecutionContext.to_h).to eq({}) }
          end,
          RSpec::Core::ExampleGroup.describe("A controller group", type: :controller) do
            specify do
              Rails.error.set_context(foo: "bar")
              expect(ActiveSupport::ExecutionContext.to_h).to eq(foo: "bar")
            end
          end,
          RSpec::Core::ExampleGroup.describe("Another group") do
            include RSpec::Rails::RailsExampleGroup
            specify { expect(ActiveSupport::ExecutionContext.to_h).to eq({}) }
          end
        ]

      results =
        groups.map do |group|
          group.run(failure_reporter) ? true : failure_reporter.exceptions
        end

      expect(results).to all be true
    end

    it 'will not leak ActiveSupport::CurrentAttributes between examples' do
      group =
        RSpec::Core::ExampleGroup.describe("A group", order: :defined) do
          include RSpec::Rails::RailsExampleGroup

          # rubocop:disable Lint/ConstantDefinitionInBlock
          class CurrentSample < ActiveSupport::CurrentAttributes
            attribute :request_id
          end
          # rubocop:enable Lint/ConstantDefinitionInBlock

          it 'sets a current attribute' do
            CurrentSample.request_id = '123'
            expect(CurrentSample.request_id).to eq('123')
          end

          it 'does not leak current attributes' do
            expect(CurrentSample.request_id).to eq(nil)
          end
        end

      expect(
        group.run(failure_reporter) ? true : failure_reporter.exceptions
      ).to be true
    end

    describe "the Rails executor" do
      let(:events) { [] }

      let(:executor) do
        events = self.events
        Class.new(ActiveSupport::Executor) do
          to_run { events << :executor_run }
          to_complete { events << :executor_complete }
        end
      end

      before do
        allow(::Rails.application).to receive(:executor).and_return(executor)
      end

      context "when executor_around_test_case is off" do
        before do
          allow(::Rails.application.config.active_support).to receive(:executor_around_test_case).and_return(false)
        end

        it "does not wrap examples in the executor" do
          events = self.events
          group =
            RSpec::Core::ExampleGroup.describe("A group") do
              include RSpec::Rails::RailsExampleGroup
              it { events << :example }
            end

          expect(
            group.run(failure_reporter) ? true : failure_reporter.exceptions
          ).to be true
          expect(events).to eq([:example])
        end
      end

      context "when executor_around_test_case is on" do
        before do
          allow(::Rails.application.config.active_support).to receive(:executor_around_test_case).and_return(true)
        end

        it "wraps examples and config.around hooks registered before rspec-rails in the executor" do
          events = self.events
          result =
            RSpec::Core::Sandbox.sandboxed do |config|
              config.around do |example|
                events << :config_around_start
                example.run
                events << :config_around_end
              end
              RSpec::Rails.initialize_configuration(config)

              group =
                RSpec::Core::ExampleGroup.describe("A group") do
                  include RSpec::Rails::RailsExampleGroup
                  it { events << :example }
                end
              group.run(failure_reporter) ? true : failure_reporter.exceptions
            end

          expect(result).to be true
          expect(events).to eq(
            [:executor_run, :config_around_start, :example, :config_around_end, :executor_complete]
          )
        end

        it "keeps current attributes that a config.around hook sets" do
          stub_const("RSpec::Rails::ExecutorSampleCurrent", Class.new(ActiveSupport::CurrentAttributes) { attribute :request_id })
          RSpec.configuration.around do |example|
            ExecutorSampleCurrent.request_id = "123"
            example.run
          end

          group =
            RSpec::Core::ExampleGroup.describe("A group") do
              include RSpec::Rails::RailsExampleGroup
              it { expect(ExecutorSampleCurrent.request_id).to eq("123") }
            end

          expect(
            group.run(failure_reporter) ? true : failure_reporter.exceptions
          ).to be true
        end

        it "wraps examples of non-Rails groups in the executor" do
          events = self.events
          group = RSpec::Core::ExampleGroup.describe("A group") { it { events << :example } }

          expect(
            group.run(failure_reporter) ? true : failure_reporter.exceptions
          ).to be true
          expect(events).to eq([:executor_run, :example, :executor_complete])
        end
      end

      it "does not wrap examples without a Rails application" do
        allow(::Rails).to receive(:application).and_return(nil)
        events = self.events
        group =
          RSpec::Core::ExampleGroup.describe("A group") do
            include RSpec::Rails::RailsExampleGroup
            it { events << :example }
          end

        expect(
          group.run(failure_reporter) ? true : failure_reporter.exceptions
        ).to be true
        expect(events).to eq([:example])
      end
    end

    it 'will not leak enqueued ActiveJob jobs between examples', skip: !RSpec::Rails::FeatureCheck.has_active_job? do
      original_adapter = ActiveJob::Base.queue_adapter
      test_adapter = ActiveJob::QueueAdapters::TestAdapter.new
      ActiveJob::Base.queue_adapter = test_adapter

      if ::Rails.version.to_f > 8.1
        # Rails 8.2 started storing test adapters in such a way as to override the settings
        # with a cached version, we need to clear that cache after changing the adapter to
        # our isolated one. See rspec/rspec-rails#2919
        ActiveJob::TestHelper::TestQueueAdapter.reset
        expect(ActiveJob::Base.queue_adapter).to eq(test_adapter)
      end

      original_logger = ActiveJob::Base.logger
      ActiveJob::Base.logger = Logger.new(nil)

      leaky_job = Class.new(ActiveJob::Base) do
        def perform; end

        def self.name
          'LeakyJob'
        end
      end

      group =
        RSpec::Core::ExampleGroup.describe("A group", order: :defined) do
          include RSpec::Rails::RailsExampleGroup

          it 'enqueues a job' do
            leaky_job.perform_later
            expect(enqueued_jobs.size).to eq(1)
          end

          it 'does not see the job enqueued in the prior example' do
            expect(enqueued_jobs).to be_empty
          end
        end

      expect(
        group.run(failure_reporter) ? true : failure_reporter.exceptions
      ).to be true
    ensure
      ActiveJob::Base.queue_adapter = original_adapter
      ActiveJob::Base.logger = original_logger
    end
  end
end
