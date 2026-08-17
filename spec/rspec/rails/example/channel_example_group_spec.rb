require "rspec/rails/feature_check"

module RSpec::Rails
  RSpec.describe ChannelExampleGroup, :with_isolated_config do
    if RSpec::Rails::FeatureCheck.has_action_cable_testing?
      it_behaves_like "an rspec-rails example group mixin", :channel,
                      './spec/channels/', '.\\spec\\channels\\'
    end
  end
end

# These groups have to name their subject class, so they cannot be declared and
# then skipped: the constants only exist when ActionCable does, and `describe`
# resolves them long before it looks at `skip` metadata.
if RSpec::Rails::FeatureCheck.has_action_cable_testing?
  class StubbedConnectionChannel < ActionCable::Channel::Base
    def subscribed
      stream_from "stubbed_#{params[:id]}" if params[:id]
    end
  end

  class StubbedConnection < ActionCable::Connection::Base
  end

  # `described_class` answers one of `channel_class`/`connection_class`, never
  # both, so each has to ignore a described class of the other kind.
  RSpec.describe StubbedConnectionChannel, type: :channel do
    it "resolves the described channel class" do
      expect(self.class.channel_class).to be(StubbedConnectionChannel)
    end

    it "stubs a connection without being given one" do
      stub_connection
      subscribe(id: 42)

      expect(subscription).to have_stream_from("stubbed_42")
    end
  end

  RSpec.describe StubbedConnection, type: :channel do
    it "resolves the described connection class" do
      expect(self.class.connection_class).to be(StubbedConnection)
    end
  end
end
