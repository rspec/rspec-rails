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

    describe "#app", :at_least_rails_3_1 do
      before do
        @orig_application = RSpec.configuration.application
        RSpec.configuration.application = RSpec::EngineExample
      end

      after do
        RSpec.configuration.application = @orig_application
      end

      it "sets app as custom application" do
        group = RSpec::Core::ExampleGroup.describe do
          include RequestExampleGroup
        end

        example = group.new

        example.app.should eq(RSpec::EngineExample)
      end
    end
  end
end
