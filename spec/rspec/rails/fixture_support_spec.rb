module RSpec::Rails
  RSpec.describe FixtureSupport, :with_isolated_config do
    context "with use_transactional_fixtures set to false" do
      it "still supports fixture_path/fixture_paths" do
        allow(RSpec.configuration).to receive(:use_transactional_fixtures) { false }
        group = RSpec::Core::ExampleGroup.describe do
          include FixtureSupport
        end

        expect(group).to respond_to(:fixture_paths)
        expect(group).to respond_to(:fixture_paths=)
      end
    end

    context "with use_transactional_tests set to true" do
      it "works with #uses_transaction helper" do
        group = RSpec::Core::ExampleGroup.describe do
          include FixtureSupport
          self.use_transactional_tests = true

          uses_transaction "doesn't run in transaction"

          it "doesn't run in transaction" do
            expect(ActiveRecord::Base.connection.transaction_open?).to eq(false)
          end

          it "runs in transaction" do
            expect(ActiveRecord::Base.connection.transaction_open?).to eq(true)
          end
        end

        expect_to_pass(group)
      end
    end

    context "with use_transactional_tests set to false" do
      it "does not wrap the test in a transaction" do
        allow(RSpec.configuration).to receive(:use_transactional_fixtures) { true }
        group = RSpec::Core::ExampleGroup.describe do
          include FixtureSupport

          self.use_transactional_tests = false

          it "doesn't run in transaction" do
            expect(ActiveRecord::Base.connection.transaction_open?).to eq(false)
          end
        end

        expect_to_pass(group)
      end
    end

    it "handles namespaced fixtures" do
      group = RSpec::Core::ExampleGroup.describe do
        include FixtureSupport
        fixtures 'namespaced/model'

        it 'has the fixture' do
          namespaced_model(:one)
        end
      end
      group.fixture_paths = [File.expand_path('../../support/fixtures', __dir__)]

      expect_to_pass(group)
    end

    def expect_to_pass(group)
      result = group.run(failure_reporter)
      failure_reporter.exceptions.map { |e| raise e }
      expect(result).to be true
    end

    context "with use_active_record set to false" do
      it "does not support fixture_path/fixture_paths" do
        allow(RSpec.configuration).to receive(:use_active_record) { false }
        group = RSpec::Core::ExampleGroup.describe do
          include FixtureSupport
        end

        expect(group).not_to respond_to(:fixture_paths)
      end

      it "does not include ActiveRecord::TestFixtures" do
        allow(RSpec.configuration).to receive(:use_active_record) { false }
        group = RSpec::Core::ExampleGroup.describe do
          include FixtureSupport
        end

        expect(group).not_to include(ActiveRecord::TestFixtures)
      end
    end
  end
end
