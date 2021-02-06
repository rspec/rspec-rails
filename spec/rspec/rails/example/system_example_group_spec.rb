module RSpec::Rails
  if ActionPack::VERSION::STRING >= "5.1"
    RSpec.describe SystemExampleGroup do
      it_behaves_like "an rspec-rails example group mixin", :system,
                      './spec/system/', '.\\spec\\system\\'

      describe '#method_name' do
        it 'converts special characters to underscores' do
          group = RSpec::Core::ExampleGroup.describe ActionPack do
            include SystemExampleGroup
          end
          SystemExampleGroup::CHARS_TO_TRANSLATE.each do |char|
            example = group.new
            example_class_mock = double('name' => "method#{char}name")
            allow(example).to receive(:class).and_return(example_class_mock)
            expect(example.send(:method_name)).to start_with('method_name')
          end
        end
      end

      describe 'rails url helpers' do
        it 'have the rails system test default host' do
          full_url = nil
          group = RSpec::Core::ExampleGroup.describe do
            include SystemExampleGroup

            specify do
              @routes.draw { get "/" => "page#index", as: :root }
              full_url = root_url
            end
          end
          group.run(failure_reporter)
          expect(failure_reporter.exceptions).to eq []
          expect(full_url).to match a_string_including(ActionDispatch::SystemTesting::TestHelpers::SetupAndTeardown::DEFAULT_HOST)
        end
      end

      describe '#url_options' do
        it 'has the rails system test default host' do
          rails_url_options = {}
          group = RSpec::Core::ExampleGroup.describe do
            include SystemExampleGroup

            specify { rails_url_options.merge!(url_options) }
          end
          group.run(failure_reporter)
          expect(failure_reporter.exceptions).to eq []

          expect(
            rails_url_options
          ).to match hash_including(host: ActionDispatch::SystemTesting::TestHelpers::SetupAndTeardown::DEFAULT_HOST)
        end
      end

      describe '#driver' do
        it 'uses :selenium driver by default' do
          group = RSpec::Core::ExampleGroup.describe do
            include SystemExampleGroup
          end
          example = group.new
          group.hooks.run(:before, :example, example)

          expect(Capybara.current_driver).to eq :selenium
        end

        it 'sets :rack_test driver using by before_action' do
          group = RSpec::Core::ExampleGroup.describe do
            include SystemExampleGroup

            before do
              driven_by(:rack_test)
            end
          end
          example = group.new
          group.hooks.run(:before, :example, example)

          expect(Capybara.current_driver).to eq :rack_test
        end

        it 'calls :driven_by method only once' do
          group = RSpec::Core::ExampleGroup.describe do
            include SystemExampleGroup

            before do
              driven_by(:rack_test)
            end
          end
          example = group.new
          allow(example).to receive(:driven_by).and_call_original
          group.hooks.run(:before, :example, example)

          expect(example).to have_received(:driven_by).once
        end
      end

      describe '#after' do
        it 'sets the :extra_failure_lines metadata to an array of STDOUT lines' do
          group = RSpec::Core::ExampleGroup.describe do
            include SystemExampleGroup

            before do
              driven_by(:selenium)
            end

            def take_screenshot
              puts 'line 1'
              puts 'line 2'
            end
          end
          example = group.it('fails') { fail }
          group.run

          expect(example.metadata[:extra_failure_lines]).to eq(["line 1\n", "line 2\n"])
        end
      end
    end
  end
end
