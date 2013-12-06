require "spec_helper"

module RSpec::Rails
  describe RoutingExampleGroup do
    it { is_expected.to be_included_in_files_in('./spec/routing/') }
    it { is_expected.to be_included_in_files_in('.\\spec\\routing\\') }

    it "adds :type => :routing to the metadata" do
      group = RSpec::Core::ExampleGroup.describe do
        include RoutingExampleGroup
      end
      expect(group.metadata[:type]).to eq(:routing)
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
        allow(example).to receive_messages(:routes => routes)

        expect(example.foo_path).to eq("foo")
      end
    end
  end
end
