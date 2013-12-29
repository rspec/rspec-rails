require "spec_helper"

module RSpec::Rails
  describe ModelExampleGroup do
    it { is_expected.to be_included_in_files_in('./spec/models/') }
    it { is_expected.to be_included_in_files_in('.\\spec\\models\\') }

    it "adds :type => :model to the metadata" do
      group = RSpec::Core::ExampleGroup.describe do
        include ModelExampleGroup
      end
      expect(group.metadata[:type]).to eq(:model)
    end
    
    it_behaves_like "runs metadata hooks of :type =>", :model, ModelExampleGroup
  end
end
