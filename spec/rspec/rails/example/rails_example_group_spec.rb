module RSpec::Rails
  RSpec.describe RailsExampleGroup do
    it 'supports tagged_logger', if: ::Rails::VERSION::MAJOR >= 7 do
      expect(described_class.private_instance_methods).to include(:tagged_logger)
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

    it 'will not leak ActiveSupport::CurrentAttributes between examples', if: ::Rails::VERSION::MAJOR >= 7 do
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

    context 'with suite-level around-example hooks configured', if: ::Rails::VERSION::MAJOR >= 7 do
      let(:uniquely_identifiable_metadata) do
        { configured_around_example_hook: true }
      end

      class CurrentAttrsBetweenHooks < ActiveSupport::CurrentAttributes
        attribute :request_id
      end

      # We have to modify the suite's around-each in RSpec.config, but don't
      # want to pollute other tests with this (whether or not it is harmless
      # to do so). There being no public API to read or remove hooks, instead
      # it's necessary use some private APIs to be able to delete the added
      # hook via 'ensure'.
      #
      around :each do | example |

        # Client code might legitimately want to wrap examples to ensure
        # all-conditions tidy-up, e.g. "ActsAsTenant.without_tenant do...",
        # wherein an "around" hook is the only available solution, often used
        # in the overall suite via "config.around". Tests would not expect
        # anything set in CurrentAttributes here to suddenly be reset by the
        # time their actual tests, or their test hooks ran.
        #
        RSpec.configure do | config |
          config.around(:each, uniquely_identifiable_metadata()) do | example |
            CurrentAttrsBetweenHooks.request_id = '123'
            example.run()
          end
        end

        example.run()

      ensure
        around_example_repository = RSpec.configuration.hooks.send(:hooks_for, :around, :example)
        item_we_added = around_example_repository.items_for(uniquely_identifiable_metadata()).first
        around_example_repository.delete(item_we_added, uniquely_identifiable_metadata())
      end

      it 'does not reset ActiveSupport::CurrentAttributes before examples' do
        group =
          RSpec::Core::ExampleGroup.describe('A group', uniquely_identifiable_metadata()) do
            include RSpec::Rails::RailsExampleGroup

            it 'runs normally' do
              expect(CurrentAttrsBetweenHooks.request_id).to eq('123')
            end
          end

        expect(
          group.run(failure_reporter) ? true : failure_reporter.exceptions
        ).to be true
      end

      it 'does not reset ActiveSupport::CurrentAttributes before before-each hooks' do
        group =
          RSpec::Core::ExampleGroup.describe('A group', uniquely_identifiable_metadata()) do
            include RSpec::Rails::RailsExampleGroup

            # Client code will often have test setup blocks within "*_spec.rb"
            # files that might set up data or other environmental factors for a
            # group of tests in e.g. a "before" hook, but would reasonably expect
            # suite-wide 'around' settings to remain intact and not be reset.
            #
            before :each do | example |
              expect(CurrentAttrsBetweenHooks.request_id).to eq('123')
              CurrentAttrsBetweenHooks.request_id = '234'
            end

            it 'runs normally' do
              expect(CurrentAttrsBetweenHooks.request_id).to eq('234')
            end
          end

        expect(
          group.run(failure_reporter) ? true : failure_reporter.exceptions
        ).to be true
      end
    end # "context 'with suite-level around-example hooks configured' ..."
  end
end
