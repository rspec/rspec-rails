require 'rspec/support/spec/in_sub_process'

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

      # rubocop:disable Lint/ConstantDefinitionInBlock
      class CurrentAttrsBetweenHooks < ActiveSupport::CurrentAttributes
        attribute :request_id
      end
      # rubocop:enable Lint/ConstantDefinitionInBlock

      # This dirties global state, so tests *MUST* remember to use
      # "in_sub_process".
      #
      def configure_rspec_to_set_current_attrs_before_around_example

        # Client code might legitimately want to wrap examples to ensure
        # all-conditions tidy-up, e.g. "ActsAsTenant.without_tenant do...",
        # wherein an "around" hook is the only available solution, often used
        # in the overall suite via "config.around". Tests would not expect
        # anything set in CurrentAttributes here to suddenly be reset by the
        # time their actual tests, or their test hooks ran.
        #
        RSpec.configure do | config |
          config.around(:each, uniquely_identifiable_metadata) do | example |
            CurrentAttrsBetweenHooks.request_id = '123'
            example.run
          end
        end
      end

      it 'does not reset ActiveSupport::CurrentAttributes before examples' do
        in_sub_process do
          group =
            RSpec::Core::ExampleGroup.describe('A group', uniquely_identifiable_metadata) do
              include RSpec::Rails::RailsExampleGroup

              it 'runs normally' do
                expect(CurrentAttrsBetweenHooks.request_id).to eq('123')
              end
            end

          expect(
            group.run(failure_reporter) ? true : failure_reporter.exceptions
          ).to be true
        end
      end

      it 'does not reset ActiveSupport::CurrentAttributes before before-each hooks' do
        in_sub_process do
          group =
            RSpec::Core::ExampleGroup.describe('A group', uniquely_identifiable_metadata) do
              include RSpec::Rails::RailsExampleGroup

              # Client code will often have test setup blocks within "*_spec.rb"
              # files that might set up data or other environmental factors for a
              # group of tests in e.g. a "before" hook, but would reasonably expect
              # suite-wide 'around' settings to remain intact and not be reset.
              #
              before :each do
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
      end
    end
  end
end
