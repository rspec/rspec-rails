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

    describe "#app" do
      before do
        if Gem::Version.new(Rails.version) >= Gem::Version.new('3.1.0')
          @orig_application = RSpec.configuration.application
          RSpec.configuration.application = RSpec::EngineExample
        end
      end

      after do
        if Gem::Version.new(Rails.version) >= Gem::Version.new('3.1.0')
          RSpec.configuration.application = @orig_application
        end
      end

      it "sets app as custom application" do
        group = RSpec::Core::ExampleGroup.describe do
          include RequestExampleGroup
        end

        example = group.new

        if Gem::Version.new(Rails.version) >= Gem::Version.new('3.1.0')
          example.app.should eq(RSpec::EngineExample)
        else
          example.app.should eq(::Rails.application)
        end
      end
    end
  end
end
