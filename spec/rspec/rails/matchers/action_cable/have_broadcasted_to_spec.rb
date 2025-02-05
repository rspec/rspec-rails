require "rspec/rails/feature_check"

if RSpec::Rails::FeatureCheck.has_action_cable_testing?
  require "rspec/rails/matchers/action_cable"

  class CableGlobalIdModel
    include GlobalID::Identification

    attr_reader :id

    def initialize(id)
      @id = id
    end

    def to_global_id(_options = {})
      @global_id ||= GlobalID.create(self, app: "rspec-suite")
    end
  end
end

RSpec.describe "have_broadcasted_to matchers", skip: !RSpec::Rails::FeatureCheck.has_action_cable_testing? do
  let(:channel) do
    Class.new(ActionCable::Channel::Base) do
      def self.channel_name
        "broadcast"
      end
    end
  end

  def broadcast(stream, msg)
    ActionCable.server.broadcast stream, msg
  end

  before do
    server = ActionCable.server
    test_adapter = ActionCable::SubscriptionAdapter::Test.new(server)
    server.instance_variable_set(:@pubsub, test_adapter)
  end

  describe "have_broadcasted_to" do
    it "raises ArgumentError when no Proc passed to expect" do
      expect {
        expect(true).to have_broadcasted_to('stream')
      }.to raise_error(ArgumentError)
    end

    it "passes with default messages count (exactly one)" do
      expect {
        broadcast('stream', 'hello')
      }.to have_broadcasted_to('stream')
    end

    it "passes when using symbol target" do
      expect {
        broadcast(:stream, 'hello')
      }.to have_broadcasted_to(:stream)
    end

    it "passes when using alias" do
      expect {
        broadcast('stream', 'hello')
      }.to broadcast_to('stream')
    end

    it "counts only messages sent in block" do
      broadcast('stream', 'one')
      expect {
        broadcast('stream', 'two')
      }.to have_broadcasted_to('stream').exactly(1)
    end

    it "passes when negated" do
      expect { }.not_to have_broadcasted_to('stream')
    end

    it "fails when message is not sent" do
      expect {
        expect { }.to have_broadcasted_to('stream')
      }.to raise_error(/expected to broadcast exactly 1 messages to stream, but broadcast 0/)
    end

    it "fails when too many messages broadcast" do
      expect {
        expect {
          broadcast('stream', 'one')
          broadcast('stream', 'two')
        }.to have_broadcasted_to('stream').exactly(1)
      }.to raise_error(/expected to broadcast exactly 1 messages to stream, but broadcast 2/)
    end

    it "reports correct number in fail error message" do
      broadcast('stream', 'one')
      expect {
        expect { }.to have_broadcasted_to('stream').exactly(1)
      }.to raise_error(/expected to broadcast exactly 1 messages to stream, but broadcast 0/)
    end

    it "fails when negated and message is sent" do
      expect {
        expect { broadcast('stream', 'one') }.not_to have_broadcasted_to('stream')
      }.to raise_error(/expected not to broadcast exactly 1 messages to stream, but broadcast 1/)
    end

    it "passes with multiple streams" do
      expect {
        broadcast('stream_a', 'A')
        broadcast('stream_b', 'B')
        broadcast('stream_c', 'C')
      }.to have_broadcasted_to('stream_a').and have_broadcasted_to('stream_b')
    end

    it "passes with :once count" do
      expect {
        broadcast('stream', 'one')
      }.to have_broadcasted_to('stream').exactly(:once)
    end

    it "passes with :twice count" do
      expect {
        broadcast('stream', 'one')
        broadcast('stream', 'two')
      }.to have_broadcasted_to('stream').exactly(:twice)
    end

    it "passes with :thrice count" do
      expect {
        broadcast('stream', 'one')
        broadcast('stream', 'two')
        broadcast('stream', 'three')
      }.to have_broadcasted_to('stream').exactly(:thrice)
    end

    it "passes with at_least count when sent messages are over limit" do
      expect {
        broadcast('stream', 'one')
        broadcast('stream', 'two')
      }.to have_broadcasted_to('stream').at_least(:once)
    end

    it "passes with at_most count when sent messages are under limit" do
      expect {
        broadcast('stream', 'hello')
      }.to have_broadcasted_to('stream').at_most(:once)
    end

    it "generates failure message with at least hint" do
      expect {
        expect { }.to have_broadcasted_to('stream').at_least(:once)
      }.to raise_error(/expected to broadcast at least 1 messages to stream, but broadcast 0/)
    end

    it "generates failure message with at most hint" do
      expect {
        expect {
          broadcast('stream', 'hello')
          broadcast('stream', 'hello')
        }.to have_broadcasted_to('stream').at_most(:once)
      }.to raise_error(/expected to broadcast at most 1 messages to stream, but broadcast 2/)
    end

    it "passes with provided data" do
      expect {
        broadcast('stream', id: 42, name: "David")
      }.to have_broadcasted_to('stream').with(id: 42, name: "David")
    end

    it "passes with provided data matchers" do
      expect {
        broadcast('stream', id: 42, name: "David", message_id: 123)
      }.to have_broadcasted_to('stream').with(a_hash_including(name: "David", id: 42))
    end

    it "passes with provided data matchers with anything" do
      expect {
        broadcast('stream', id: 42, name: "David", message_id: 123)
      }.to have_broadcasted_to('stream').with({ name: anything, id: anything, message_id: anything })
    end

    it "generates failure message when data not match" do
      expect {
        expect {
          broadcast('stream', id: 42, name: "David", message_id: 123)
        }.to have_broadcasted_to('stream').with(a_hash_including(name: "John", id: 42))
      }.to raise_error(/expected to broadcast exactly 1 messages to stream with a hash including/)
    end

    it "throws descriptive error when no test adapter set" do
      require "action_cable/subscription_adapter/inline"
      ActionCable.server.instance_variable_set(:@pubsub, ActionCable::SubscriptionAdapter::Inline)
      expect {
        expect { broadcast('stream', 'hello') }.to have_broadcasted_to('stream')
      }.to raise_error("To use ActionCable matchers set `adapter: test` in your cable.yml")
    end

    it "fails with with block with incorrect data" do
      expect {
        expect {
          broadcast('stream', "asdf")
        }.to have_broadcasted_to('stream').with { |data|
          expect(data).to eq("zxcv")
        }
      }.to raise_error { |e|
        expect(e.message).to match(/expected: "zxcv"/)
        expect(e.message).to match(/got: "asdf"/)
      }
    end

    context "when object is passed as first argument" do
      let(:model) { CableGlobalIdModel.new(42) }

      context "when channel is present" do
        it "passes" do
          expect {
            channel.broadcast_to(model, text: 'Hi')
          }.to have_broadcasted_to(model).from_channel(channel)
        end
      end

      context "when channel can't be inferred" do
        it "raises exception" do
          expect {
            expect {
              channel.broadcast_to(model, text: 'Hi')
            }.to have_broadcasted_to(model)
          }.to raise_error(ArgumentError)
        end
      end
    end

    it "has an appropriate description" do
      expect(have_broadcasted_to("my_stream").description).to eq("have broadcasted exactly 1 messages to my_stream")
    end

    it "has an appropriate description when aliased" do
      expect(broadcast_to("my_stream").description).to eq("broadcast exactly 1 messages to my_stream")
    end

    it "has an appropriate description when stream name is passed as an array" do
      expect(have_broadcasted_to(%w[my_stream stream_2]).from_channel(channel).description).to eq("have broadcasted exactly 1 messages to broadcast:my_stream:stream_2")
    end

    it "has an appropriate description not mentioning the channel when qualified with `#from_channel`" do
      expect(have_broadcasted_to("my_stream").from_channel(channel).description).to eq("have broadcasted exactly 1 messages to my_stream")
    end

    it "has an appropriate description including the expected contents when qualified with `#with`" do
      expect(have_broadcasted_to("my_stream").from_channel(channel).with("hello world").description).to eq("have broadcasted exactly 1 messages to my_stream with \"hello world\"")
    end

    it "has an appropriate description including the matcher's description when qualified with `#with` and a composable matcher" do
      description = have_broadcasted_to("my_stream")
          .from_channel(channel)
          .with(a_hash_including(a: :b))
          .description

      if RUBY_VERSION >= '3.4'
        expect(description).to eq("have broadcasted exactly 1 messages to my_stream with a hash including {a: :b}")
      else
        expect(description).to eq("have broadcasted exactly 1 messages to my_stream with a hash including {:a => :b}")
      end
    end
  end
end
