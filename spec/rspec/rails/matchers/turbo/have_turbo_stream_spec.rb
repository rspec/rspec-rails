require "active_support"
require "active_support/test_case"
require "rspec/rails/matchers/base_matcher"
require "rspec/rails/matchers/turbo"

RSpec.describe "have_turbo_stream matcher" do
  include RSpec::Rails::Matchers::Turbo

  let(:response) { double("response") }

  describe "have_turbo_stream" do
    context "when assert_select passes" do
      def assert_select(*); end

      it "passes" do
        expect(response).to have_turbo_stream(action: "append", target: "messages")
      end
    end

    context "when assert_select fails" do
      def assert_select(*)
        raise ActiveSupport::TestCase::Assertion, "this message"
      end

      it "uses failure message from assert_select" do
        expect {
          expect(response).to have_turbo_stream(action: "append", target: "messages")
        }.to raise_exception("this message")
      end
    end

    context "when assert_select raises a non-assertion error" do
      def assert_select(*)
        raise "oops"
      end

      it "raises that exception" do
        expect {
          expect(response).to have_turbo_stream(action: "append", target: "messages")
        }.to raise_exception("oops")
      end
    end

    context "with should_not" do
      context "when assert_select fails" do
        def assert_select(*)
          raise ActiveSupport::TestCase::Assertion, "this message"
        end

        it "passes" do
          expect {
            expect(response).not_to have_turbo_stream(action: "append", target: "messages")
          }.not_to raise_exception
        end
      end

      context "when assert_select passes" do
        def assert_select(*); end

        it "fails with custom failure message" do
          expect {
            expect(response).not_to have_turbo_stream(action: "append", target: "messages")
          }.to raise_exception(/expected response not to/)
        end
      end
    end

    context "with action and target" do
      attr_accessor :selector_received

      def assert_select(selector, **_opts)
        self.selector_received = selector
      end

      it "builds the correct selector" do
        have_turbo_stream(action: "append", target: "messages").matches?(response)
        expect(selector_received).to eq('turbo-stream[action="append"][target="messages"]')
      end

      it "converts symbol action to string" do
        have_turbo_stream(action: :remove, target: "post_1").matches?(response)
        expect(selector_received).to include('action="remove"')
      end
    end

    context "with action and targets" do
      attr_accessor :selector_received

      def assert_select(selector, **_opts)
        self.selector_received = selector
      end

      it "builds the correct selector with targets attribute" do
        have_turbo_stream(action: "update", targets: ".comments").matches?(response)
        expect(selector_received).to eq('turbo-stream[action="update"][targets=".comments"]')
      end
    end

    context "with_count" do
      attr_accessor :opts_received

      def assert_select(_selector, **opts)
        self.opts_received = opts
      end

      it "passes count to assert_select" do
        have_turbo_stream(action: "append", target: "items").with_count(2).matches?(response)
        expect(opts_received).to eq(count: 2)
      end

      it "does not pass count when with_count is not called" do
        have_turbo_stream(action: "append", target: "items").matches?(response)
        expect(opts_received).to eq({})
      end
    end

    context "argument validation" do
      it "raises ArgumentError when neither target nor targets is provided" do
        expect {
          have_turbo_stream(action: "append")
        }.to raise_error(ArgumentError, /must specify either :target or :targets/)
      end

      it "raises ArgumentError when both target and targets are provided" do
        expect {
          have_turbo_stream(action: "append", target: "foo", targets: ".bar")
        }.to raise_error(ArgumentError, /cannot specify both/)
      end
    end

    describe "#description" do
      it "describes action and target" do
        matcher = have_turbo_stream(action: "append", target: "messages")
        expect(matcher.description).to eq('have turbo stream "append" targeting "messages"')
      end

      it "describes action and targets" do
        matcher = have_turbo_stream(action: "update", targets: ".items")
        expect(matcher.description).to eq('have turbo stream "update" targeting ".items"')
      end

      it "includes count when specified" do
        matcher = have_turbo_stream(action: "append", target: "messages").with_count(3)
        expect(matcher.description).to eq('have turbo stream "append" targeting "messages" 3 time(s)')
      end
    end

    describe "#failure_message_when_negated" do
      it "describes what was not expected" do
        matcher = have_turbo_stream(action: "append", target: "messages")
        expect(matcher.failure_message_when_negated).to include("not to")
      end
    end
  end

  describe "be_turbo_stream" do
    def response_with(media_type:)
      double("response", media_type: media_type, content_type: "#{media_type}; charset=utf-8")
    end

    it "passes when response has turbo stream media type" do
      response = response_with(media_type: "text/vnd.turbo-stream.html")
      expect(response).to be_turbo_stream
    end

    it "fails when response has html media type" do
      response = response_with(media_type: "text/html")
      expect(response).not_to be_turbo_stream
    end

    it "fails when response has json media type" do
      response = response_with(media_type: "application/json")
      expect(response).not_to be_turbo_stream
    end

    describe "#description" do
      it "describes the matcher" do
        expect(be_turbo_stream.description).to eq("be a Turbo Stream response")
      end
    end

    describe "#failure_message" do
      it "includes expected and actual media types" do
        matcher = be_turbo_stream
        response = response_with(media_type: "text/html")
        matcher.matches?(response)
        expect(matcher.failure_message).to include("text/vnd.turbo-stream.html")
        expect(matcher.failure_message).to include("text/html")
      end
    end

    context "when response only has content_type" do
      it "extracts media type from content_type" do
        response = double("response", content_type: "text/vnd.turbo-stream.html; charset=utf-8")
        allow(response).to receive(:respond_to?).with(:media_type).and_return(false)
        allow(response).to receive(:respond_to?).with(:content_type).and_return(true)
        expect(response).to be_turbo_stream
      end
    end
  end
end
