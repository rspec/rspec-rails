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
  end
end
