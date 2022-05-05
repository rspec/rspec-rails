module RSpec::Rails
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

      it "handles long method names which include unicode characters" do
        group =
          RSpec::Core::ExampleGroup.describe do
            include SystemExampleGroup
          end

        example = group.new
        allow(example.class).to receive(:name) { "really long unicode example name - #{'あ'*100}" }

        expect(example.send(:method_name).bytesize).to be <= 210
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
        allow(Capybara::Session).to receive(:instance_created?).and_return(true)
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

    describe "hook order" do
      it 'calls Capybara.reset_sessions (TestUnit after_teardown) after any after hooks' do
        calls_in_order = []
        allow(Capybara).to receive(:reset_sessions!) { calls_in_order << :reset_sessions! }

        group = RSpec::Core::ExampleGroup.describe do
          include SystemExampleGroup

          before do
            driven_by(:selenium)
          end

          after do
            calls_in_order << :after_hook
          end

          append_after do
            calls_in_order << :append_after_hook
          end

          around do |example|
            example.run
            calls_in_order << :around_hook_after_example
          end
        end
        group.it('works') { }
        group.run

        expect(calls_in_order).to eq([:after_hook, :append_after_hook, :around_hook_after_example, :reset_sessions!])
      end

    end
  end
end
