require "spec_helper"

%w[have_rendered render_template].each do |template_expectation|
  describe template_expectation do
    include RSpec::Rails::Matchers::RenderTemplate
    let(:response) { ActionController::TestResponse.new }

    context "given a hash" do
      it "delegates to assert_template" do
        self.should_receive(:assert_template).with({:this => "hash"}, "this message")
        expect("response").to send(template_expectation, {:this => "hash"}, "this message")
      end
    end

    context "given a string" do
      it "delegates to assert_template" do
        self.should_receive(:assert_template).with("this string", "this message")
        expect("response").to send(template_expectation, "this string", "this message")
      end
    end

    context "given a symbol" do
      it "converts to_s and delegates to assert_template" do
        self.should_receive(:assert_template).with("template_name", "this message")
        expect("response").to send(template_expectation, :template_name, "this message")
      end
    end

    context "with should" do
      context "when assert_template passes" do
        it "passes" do
          self.stub!(:assert_template)
          expect do
            expect(response).to send(template_expectation, "template_name")
          end.to_not raise_exception
        end
      end

      context "when assert_template fails" do
        it "uses failure message from assert_template" do
          self.stub!(:assert_template) do
            raise ActiveSupport::TestCase::Assertion.new("this message")
          end
          expect do
            expect(response).to send(template_expectation, "template_name")
          end.to raise_error("this message")
        end
      end

      context "when fails due to some other exception" do
        it "raises that exception" do
          self.stub!(:assert_template) do
            raise "oops"
          end
          expect do
            expect(response).to send(template_expectation, "template_name")
          end.to raise_exception("oops")
        end
      end
    end

    context "with should_not" do
      context "when assert_template fails" do
        it "passes" do
          def assert_template(*)
            raise ActiveSupport::TestCase::Assertion.new("this message")
          end
          expect do
            expect(response).to_not send(template_expectation, "template_name")
          end.to_not raise_exception
        end
      end

      context "when assert_template passes" do
        it "fails with custom failure message" do
          def assert_template(*); end
          expect do
            expect(response).to_not send(template_expectation, "template_name")
          end.to raise_error(/expected not to render \"template_name\", but did/)
        end
      end

      context "when fails due to some other exception" do
        it "raises that exception" do
          def assert_template(*); raise "oops"; end
          expect do
            expect(response).to_not send(template_expectation, "template_name")
          end.to raise_exception("oops")
        end
      end
    end
  end
end
