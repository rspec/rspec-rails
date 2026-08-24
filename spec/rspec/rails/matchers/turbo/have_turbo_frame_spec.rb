require "active_support"
require "active_support/test_case"
require "rspec/rails/matchers/base_matcher"
require "rspec/rails/matchers/turbo"

RSpec.describe "have_turbo_frame matcher" do
  include RSpec::Rails::Matchers::Turbo

  let(:response) { double("response") }

  describe "have_turbo_frame" do
    context "when assert_select passes" do
      def assert_select(*); end

      it "passes" do
        expect(response).to have_turbo_frame("post_form")
      end
    end

    context "when assert_select fails" do
      def assert_select(*)
        raise ActiveSupport::TestCase::Assertion, "this message"
      end

      it "uses failure message from assert_select" do
        expect {
          expect(response).to have_turbo_frame("post_form")
        }.to raise_exception("this message")
      end
    end

    context "when assert_select raises a non-assertion error" do
      def assert_select(*)
        raise "oops"
      end

      it "raises that exception" do
        expect {
          expect(response).to have_turbo_frame("post_form")
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
            expect(response).not_to have_turbo_frame("post_form")
          }.not_to raise_exception
        end
      end

      context "when assert_select passes" do
        def assert_select(*); end

        it "fails with custom failure message" do
          expect {
            expect(response).not_to have_turbo_frame("post_form")
          }.to raise_exception(/expected response not to/)
        end
      end
    end

    context "selector building" do
      attr_accessor :selector_received

      def assert_select(selector, **_opts)
        self.selector_received = selector
      end

      it "builds the correct selector" do
        have_turbo_frame("post_form").matches?(response)
        expect(selector_received).to eq('turbo-frame[id="post_form"]')
      end

      it "converts symbol id to string" do
        have_turbo_frame(:post_form).matches?(response)
        expect(selector_received).to include('id="post_form"')
      end
    end

    describe "#description" do
      it "describes the expected frame" do
        matcher = have_turbo_frame("post_form")
        expect(matcher.description).to eq('have turbo frame "post_form"')
      end
    end

    describe "#failure_message_when_negated" do
      it "describes what was not expected" do
        matcher = have_turbo_frame("post_form")
        expect(matcher.failure_message_when_negated).to include("not to")
        expect(matcher.failure_message_when_negated).to include("post_form")
      end
    end
  end
end
