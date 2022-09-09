module RSpec::Rails
  RSpec.describe RailsExampleGroup do
    if ::Rails::VERSION::MAJOR >= 7
      it 'includes ActiveSupport::Testing::TaggedLogging' do
        expect(described_class.include?(::ActiveSupport::Testing::TaggedLogging)).to eq(true)
        expect(described_class.private_instance_methods).to include(:tagged_logger)
      end
    end
  end
end
