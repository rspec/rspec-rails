module RSpec::Rails
  RSpec.describe RailsExampleGroup do
    if ::Rails::VERSION::MAJOR >= 7
      it 'supports tagged_logger' do
        expect(described_class.private_instance_methods).to include(:tagged_logger)
      end
    end
  end
end
