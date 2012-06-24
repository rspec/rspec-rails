require "spec_helper"

module RSpec::Rails
  describe RoutingExampleGroup do
    it { should be_included_in_files_in('./spec/routing/') }
    it { should be_included_in_files_in('.\\spec\\routing\\') }

    it "adds :type => :routing to the metadata" do
      group = RSpec::Core::ExampleGroup.describe do
        include RoutingExampleGroup
      end
      group.metadata[:type].should eq(:routing)
    end

    describe "named routes" do
      it "delegates them to the route_set" do
        group = RSpec::Core::ExampleGroup.describe do
          include RoutingExampleGroup
        end

        example = group.new

        # Yes, this is quite invasive
        url_helpers = double('url_helpers', :foo_path => "foo")
        routes = double('routes', :url_helpers => url_helpers)
        example.stub(:routes => routes)

        example.foo_path.should == "foo"
      end
    end

    describe "custom application", :at_least_rails_3_1 do
      it "provides routes of the custom application" do
        group = RSpec::Core::ExampleGroup.describe do
          include RoutingExampleGroup
        end

        example = group.new

        # Because this relies on before hooks, I have to stub this in.
        example.stub(:routes => RSpec.configuration.application.routes)
        example.bars_path.should == "/bars"
      end
    end
  end
end
