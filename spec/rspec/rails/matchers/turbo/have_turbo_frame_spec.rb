require "rspec/rails/matchers/turbo/have_turbo_frame"

RSpec.describe "have_turbo_frame matcher" do
  def have_turbo_frame(id)
    RSpec::Rails::Matchers::Turbo::HaveTurboFrame.new(id)
  end

  def response_with(body:)
    double("response", body: body)
  end

  describe "have_turbo_frame" do
    it "passes when matching turbo-frame is present" do
      response = response_with(body: '<turbo-frame id="post_form"><form>...</form></turbo-frame>')
      expect(response).to have_turbo_frame("post_form")
    end

    it "fails when no matching turbo-frame is present" do
      response = response_with(body: '<turbo-frame id="other_frame"><div>...</div></turbo-frame>')
      expect(response).not_to have_turbo_frame("post_form")
    end

    it "fails when body is empty" do
      response = response_with(body: "")
      expect(response).not_to have_turbo_frame("post_form")
    end

    it "fails when body has no turbo-frame elements" do
      response = response_with(body: "<div>No frames here</div>")
      expect(response).not_to have_turbo_frame("post_form")
    end

    it "accepts symbol id" do
      response = response_with(body: '<turbo-frame id="post_form"><form>...</form></turbo-frame>')
      expect(response).to have_turbo_frame(:post_form)
    end

    context "with nested turbo frames" do
      let(:body) do
        <<~HTML
          <turbo-frame id="outer">
            <turbo-frame id="inner">
              <div>Content</div>
            </turbo-frame>
          </turbo-frame>
        HTML
      end

      it "matches outer frame" do
        expect(response_with(body: body)).to have_turbo_frame("outer")
      end

      it "matches inner frame" do
        expect(response_with(body: body)).to have_turbo_frame("inner")
      end
    end

    describe "#description" do
      it "describes the expected frame" do
        matcher = have_turbo_frame("post_form")
        expect(matcher.description).to eq('have turbo frame "post_form"')
      end
    end

    describe "#failure_message" do
      it "describes what was expected" do
        matcher = have_turbo_frame("post_form")
        matcher.matches?(response_with(body: ""))
        expect(matcher.failure_message).to include("post_form")
        expect(matcher.failure_message).to include("<turbo-frame>")
      end
    end

    describe "#failure_message_when_negated" do
      it "describes what was not expected" do
        matcher = have_turbo_frame("post_form")
        expect(matcher.failure_message_when_negated).to include("not to")
        expect(matcher.failure_message_when_negated).to include("post_form")
      end
    end

    describe "#does_not_match?" do
      it "returns true when frame is not found" do
        matcher = have_turbo_frame("missing")
        expect(matcher.does_not_match?(response_with(body: "<div>no frames</div>"))).to be true
      end

      it "returns false when frame is found" do
        matcher = have_turbo_frame("present")
        expect(matcher.does_not_match?(response_with(body: '<turbo-frame id="present"></turbo-frame>'))).to be false
      end
    end
  end
end
