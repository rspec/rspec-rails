require "spec_helper"

module RSpec::Rails
  describe RequestExampleGroup do
    it { should be_included_in_files_in('./spec/requests/') }
    it { should be_included_in_files_in('./spec/integration/') }
    it { should be_included_in_files_in('.\\spec\\requests\\') }
    it { should be_included_in_files_in('.\\spec\\integration\\') }

    it "adds :type => :request to the metadata" do
      group = RSpec::Core::ExampleGroup.describe do
        include RequestExampleGroup
      end
      group.metadata[:type].should eq(:request)
    end

    describe '#app' do
      it 'returns the RSpec.configuration.application' do
        group = RSpec::Core::ExampleGroup.describe do
          include RequestExampleGroup
        end

        example = group.new

        example.app.should eq(RSpec.configuration.application)
      end
    end
  end
end
