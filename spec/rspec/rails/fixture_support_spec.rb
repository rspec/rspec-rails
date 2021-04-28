module RSpec::Rails
  RSpec.describe FixtureSupport do
    context "with use_transactional_fixtures set to false" do
      it "still supports fixture_path" do
        allow(RSpec.configuration).to receive(:use_transactional_fixtures) { false }
        group = RSpec::Core::ExampleGroup.describe do
          include FixtureSupport
        end

        expect(group).to respond_to(:fixture_path)
        expect(group).to respond_to(:fixture_path=)
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

      def expect_to_pass(group)
        result = group.run(failure_reporter)
        failure_reporter.exceptions.map { |e| raise e }
        expect(result).to be true
      end
    end

    it "will allow #setup_fixture to run successfully", skip: Rails.version.to_f <= 6.0 do
      group = RSpec::Core::ExampleGroup.describe do
        include FixtureSupport

        self.use_transactional_tests = false
      end

      expect { group.new.setup_fixtures }.to_not raise_error
    end
  end
end
