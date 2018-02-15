require "spec_helper"
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
    end
  end
end
