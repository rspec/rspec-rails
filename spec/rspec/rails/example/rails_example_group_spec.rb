module RSpec::Rails
  RSpec.describe RailsExampleGroup do
    if ::Rails::VERSION::MAJOR >= 7
      it 'supports tagged_logger' do
        expect(described_class.private_instance_methods).to include(:tagged_logger)
      end
    end

    it 'does not leak context between example groups', if: ::Rails::VERSION::MAJOR >= 7 do
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

    describe 'CurrentAttributes', order: :defined do
      class Current < ActiveSupport::CurrentAttributes
        attribute :request_id
      end

      it 'sets a current attribute' do
        Current.request_id = '123'
        expect(Current.request_id).to eq('123')
        expect(Current.attributes).to eq(request_id: '123')
      end

      it 'does not leak current attributes' do
        expect(Current.request_id).to eq(nil)
        expect(Current.attributes).to eq({})
      end
    end
  end
end
