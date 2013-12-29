require "spec_helper"

module RSpec::Rails
  describe RequestExampleGroup do
    it { is_expected.to be_included_in_files_in('./spec/requests/') }
    it { is_expected.to be_included_in_files_in('./spec/integration/') }
    it { is_expected.to be_included_in_files_in('.\\spec\\requests\\') }
    it { is_expected.to be_included_in_files_in('.\\spec\\integration\\') }

    it "adds :type => :request to the metadata" do
      group = RSpec::Core::ExampleGroup.describe do
        include RequestExampleGroup
      end
      expect(group.metadata[:type]).to eq(:request)
    end

    it_behaves_like "runs metadata hooks of :type =>", :request, RequestExampleGroup
  end
end
