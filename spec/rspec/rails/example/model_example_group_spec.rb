require "spec_helper"

module RSpec::Rails
  describe ModelExampleGroup do
    it_behaves_like "an rspec-rails example group mixin", :model,
      './spec/models/', '.\\spec\\models\\'

    it "adds :type => :model to the metadata" do
      group = RSpec::Core::ExampleGroup.describe do
        include ModelExampleGroup
      end
      expect(group.metadata[:type]).to eq(:model)
    end
  end
end
