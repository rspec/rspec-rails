module RSpec::Rails
  RSpec.describe FixtureSupport do
    context "with use_transactional_fixtures set to false" do
      it "still supports fixture_path" do
        allow(RSpec.configuration).to \
          receive(:use_transactional_fixtures) { false }
        group = RSpec::Core::ExampleGroup.describe do
          include FixtureSupport
        end

        expect(group).to respond_to(:fixture_path)
        expect(group).to respond_to(:fixture_path=)
      end
    end

    it "will allow #setup_fixture to run successfully", if: Rails.version.to_f > 6.0 do
      group = RSpec::Core::ExampleGroup.describe do
        include FixtureSupport

        self.use_transactional_tests = false
      end

      expect { group.new.setup_fixtures }.to_not raise_error
    end

    context "without database available" do
      let(:example_group) do
        RSpec::Core::ExampleGroup.describe("FixtureSupport") do
          include FixtureSupport
          include RSpec::Rails::MinitestLifecycleAdapter
        end
      end
      let(:example) do
        example_group.example("foo") do
          expect(true).to be(true)
        end
      end

      RSpec.shared_examples_for "unrelated example raise" do
        it "raise due to no connection established" do
          expect(example_group.run).to be(false)
          expect(example.execution_result.exception).to \
            be_a(ActiveRecord::ConnectionNotEstablished)
        end
      end

      RSpec.shared_examples_for "unrelated example does not raise" do
        it "does not raise" do
          expect(example_group.run).to be(true)
          expect(example.execution_result.exception).not_to \
            be_a(ActiveRecord::ConnectionNotEstablished)
        end
      end

      before { clear_active_record_connection }

      after { establish_active_record_connection }

      context "with use_active_record set to false" do
        before { RSpec.configuration.use_active_record = false }

        after { RSpec.configuration.use_active_record = true }

        include_examples "unrelated example does not raise"
      end

      context "with use_active_record set to true" do
        before { RSpec.configuration.use_active_record = true }

        if Rails.version.to_f >= 4.0
          include_examples "unrelated example does not raise"
        else
          include_examples "unrelated example raise"
        end
      end
    end
  end
end
