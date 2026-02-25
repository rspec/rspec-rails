require "rspec/rails/feature_check"
require "rspec/rails/matchers/turbo/have_turbo_stream"

RSpec.describe "have_turbo_stream matcher" do
  include RSpec::Rails::Matchers::Turbo

  def have_turbo_stream(**opts)
    RSpec::Rails::Matchers::Turbo::HaveTurboStream.new(**opts)
  end

  def response_with(body:, media_type: "text/vnd.turbo-stream.html")
    double("response", body: body, media_type: media_type, content_type: "#{media_type}; charset=utf-8")
  end

  describe "have_turbo_stream" do
    context "with action and target" do
      it "passes when matching turbo-stream element is present" do
        response = response_with(body: '<turbo-stream action="append" target="messages"><template><div>Hello</div></template></turbo-stream>')
        expect(response).to have_turbo_stream(action: "append", target: "messages")
      end

      it "fails when no matching turbo-stream element is present" do
        response = response_with(body: '<turbo-stream action="replace" target="other"><template></template></turbo-stream>')
        expect(response).not_to have_turbo_stream(action: "append", target: "messages")
      end

      it "fails when body is empty" do
        response = response_with(body: "")
        expect(response).not_to have_turbo_stream(action: "append", target: "messages")
      end

      it "matches action as string or symbol" do
        response = response_with(body: '<turbo-stream action="remove" target="post_1"><template></template></turbo-stream>')
        expect(response).to have_turbo_stream(action: :remove, target: "post_1")
      end
    end

    context "with action and targets" do
      it "passes when matching turbo-stream element with targets is present" do
        response = response_with(body: '<turbo-stream action="update" targets=".comments"><template><div>Updated</div></template></turbo-stream>')
        expect(response).to have_turbo_stream(action: "update", targets: ".comments")
      end

      it "fails when targets don't match" do
        response = response_with(body: '<turbo-stream action="update" targets=".posts"><template></template></turbo-stream>')
        expect(response).not_to have_turbo_stream(action: "update", targets: ".comments")
      end
    end

    context "with multiple turbo-stream elements" do
      let(:body) do
        <<~HTML
          <turbo-stream action="append" target="messages"><template><div>One</div></template></turbo-stream>
          <turbo-stream action="append" target="messages"><template><div>Two</div></template></turbo-stream>
          <turbo-stream action="replace" target="count"><template><span>2</span></template></turbo-stream>
        HTML
      end

      it "passes when at least one element matches" do
        response = response_with(body: body)
        expect(response).to have_turbo_stream(action: "append", target: "messages")
      end

      it "passes with correct count" do
        response = response_with(body: body)
        expect(response).to have_turbo_stream(action: "append", target: "messages").with_count(2)
      end

      it "fails with incorrect count" do
        response = response_with(body: body)
        expect(response).not_to have_turbo_stream(action: "append", target: "messages").with_count(3)
      end
    end

    context "with_count" do
      it "passes when exactly N elements match" do
        body = '<turbo-stream action="append" target="items"><template></template></turbo-stream>'
        response = response_with(body: body)
        expect(response).to have_turbo_stream(action: "append", target: "items").with_count(1)
      end

      it "fails when count doesn't match" do
        body = '<turbo-stream action="append" target="items"><template></template></turbo-stream>'
        response = response_with(body: body)
        expect(response).not_to have_turbo_stream(action: "append", target: "items").with_count(2)
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

    describe "#failure_message" do
      it "describes what was expected" do
        matcher = have_turbo_stream(action: "append", target: "messages")
        response = response_with(body: "")
        matcher.matches?(response)
        expect(matcher.failure_message).to include('have turbo stream "append" targeting "messages"')
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
    def be_turbo_stream
      RSpec::Rails::Matchers::Turbo::BeTurboStream.new
    end

    it "passes when response has turbo stream media type" do
      response = response_with(body: "", media_type: "text/vnd.turbo-stream.html")
      expect(response).to be_turbo_stream
    end

    it "fails when response has html media type" do
      response = response_with(body: "", media_type: "text/html")
      expect(response).not_to be_turbo_stream
    end

    it "fails when response has json media type" do
      response = response_with(body: "", media_type: "application/json")
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
        response = response_with(body: "", media_type: "text/html")
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
