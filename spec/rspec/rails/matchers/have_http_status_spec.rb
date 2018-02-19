require 'spec_helper'

RSpec.describe "have_http_status" do
  def create_response(opts = {})
    ActionDispatch::TestResponse.new(opts.fetch(:status)).tap {|x|
      x.request = ActionDispatch::Request.new({})
    }
  end

  shared_examples_for "supports different response instances" do
    context "given an ActionDispatch::Response" do
      it "returns true for a response with the same code" do
        response = ::ActionDispatch::Response.new(code).tap {|x|
          x.request = ActionDispatch::Request.new({})
        }

        expect( matcher.matches?(response) ).to be(true)
      end
    end

    context "given an ActionDispatch::TestResponse" do
      it "returns true for a response with the same code" do
        response = ::ActionDispatch::TestResponse.new(code).tap {|x|
          x.request = ActionDispatch::Request.new({})
        }

        expect( matcher.matches?(response) ).to be(true)
      end
    end

    context "given something that acts as a Capybara::Session" do
      it "returns true for a response with the same code" do
        response = instance_double(
          '::Capybara::Session',
          :status_code => code,
          :response_headers => {},
          :body => ""
        )

        expect( matcher.matches?(response) ).to be(true)
      end
    end

    it "returns false given another type" do
      response = Object.new

      expect( matcher.matches?(response) ).to be(false)
    end

    it "has a failure message reporting it was given another type" do
      response = Object.new

      expect{ matcher.matches?(response) }.
        to change(matcher, :failure_message).
        to("expected a response object, but an instance of Object was received")
    end

    it "has a negated failure message reporting it was given another type" do
      response = Object.new

      expect{ matcher.matches?(response) }.
        to change(matcher, :failure_message_when_negated).
        to("expected a response object, but an instance of Object was received")
    end
  end

  context "with a numeric status code" do
    it_behaves_like "supports different response instances" do
      subject(:matcher) { have_http_status(code) }

      let(:code) { 209 }
    end

    describe "matching a response" do
      it "returns true for a response with the same code" do
        any_numeric_code  = 209
        have_numeric_code = have_http_status(any_numeric_code)
        response          = create_response(:status => any_numeric_code)

        expect( have_numeric_code.matches?(response) ).to be(true)
      end

      it "returns false for a response with a different code" do
        any_numeric_code  = 209
        have_numeric_code = have_http_status(any_numeric_code)
        response          = create_response(:status => any_numeric_code + 1)

        expect( have_numeric_code.matches?(response) ).to be(false)
      end
    end

    it "describes responding with the numeric status code" do
      any_numeric_code  = 209
      have_numeric_code = have_http_status(any_numeric_code)

      expect(have_numeric_code.description).
        to eq("respond with numeric status code 209")
    end

    it "has a failure message reporting the expected and actual status codes" do
      any_numeric_code  = 209
      have_numeric_code = have_http_status(any_numeric_code)
      response          = create_response(:status => any_numeric_code + 1)

      expect{ have_numeric_code.matches? response }.
        to change(have_numeric_code, :failure_message).
        to("expected the response to have status code 209 but it was 210")
    end

    it "has a negated failure message reporting the expected status code" do
      any_numeric_code  = 209
      have_numeric_code = have_http_status(any_numeric_code)

      expect( have_numeric_code.failure_message_when_negated ).
        to eq("expected the response not to have status code 209 but it did")
    end
  end

  context "with a symbolic status" do
    # :created => 201 status code
    # see http://guides.rubyonrails.org/layouts_and_rendering.html#the-status-option
    let(:created_code) { 201 }
    let(:created_symbolic_status) { :created }

    it_behaves_like "supports different response instances" do
      subject(:matcher) { have_http_status(created_symbolic_status) }

      let(:code) { created_code }
    end

    describe "matching a response" do
      it "returns true for a response with the equivalent code" do
        any_symbolic_status  = created_symbolic_status
        have_symbolic_status = have_http_status(any_symbolic_status)
        response             = create_response(:status => created_code)

        expect( have_symbolic_status.matches?(response) ).to be(true)
      end

      it "returns false for a response with a different code" do
        any_symbolic_status  = created_symbolic_status
        have_symbolic_status = have_http_status(any_symbolic_status)
        response             = create_response(:status => created_code + 1)

        expect( have_symbolic_status.matches?(response) ).to be(false)
      end
    end

    it "describes responding by the symbolic and associated numeric status code" do
      any_symbolic_status  = created_symbolic_status
      have_symbolic_status = have_http_status(any_symbolic_status)

      expect(have_symbolic_status.description).
        to eq("respond with status code :created (201)")
    end

    it "has a failure message reporting the expected and actual statuses" do
      any_symbolic_status  = created_symbolic_status
      have_symbolic_status = have_http_status(any_symbolic_status)
      response             = create_response(:status => created_code + 1)

      expect{ have_symbolic_status.matches? response }.
        to change(have_symbolic_status, :failure_message).
        to("expected the response to have status code :created (201) but it was :accepted (202)")
    end

    it "has a negated failure message reporting the expected status code" do
      any_symbolic_status  = created_symbolic_status
      have_symbolic_status = have_http_status(any_symbolic_status)

      expect( have_symbolic_status.failure_message_when_negated ).
        to eq("expected the response not to have status code :created (201) but it did")
    end

    it "raises an ArgumentError" do
      expect{ have_http_status(:not_a_status) }.to raise_error ArgumentError
    end
  end

  shared_examples_for "response statuses" do |code, http_status_symbol|
    let(:http_status_result) { have_http_status(http_status_symbol)}

    it "returns true for a response with a #{code} status code" do
      response = create_response(:status => code)
      expect( http_status_result.matches?(response) ).to be(true)
    end

    it "returns true for a response which starts with the same number (i.e. 4XX and 4ZZ) " do
      if code == 404
        response = create_response(:status => (  (code.digits.first.to_s + "0" + "1" ).to_i) )
        expect(http_status_result.matches?(response)).to be(false)
      else
        response = create_response(:status => (  (code.digits.first.to_s + "0" + "1" ).to_i) )
        expect(http_status_result.matches?(response)).to be(true)
      end
    end

    it "responds with the start of the relevant description" do
      expect(http_status_result.description).to eq("respond with #{http_status_symbol.articleize} status code (#{print_code(code)})")
    end

    it "has a failure message reporting the expected and actual status codes" do
      error_code = 666
      response  = create_response(:status => error_code)

      expect{ http_status_result.matches? response }.
      to change(http_status_result, :failure_message).
      to("expected the response to have #{http_status_symbol.articleize} status code (#{print_code(code)}) but it was 666")
    end

    it "has a negated failure message reporting the expected and actual status codes" do
      error_code = 666
      response     = create_response(:status => error_code)

      expect{ http_status_result.matches? response }.
      to change(http_status_result, :failure_message_when_negated).
      to("expected the response not to have #{http_status_symbol.articleize} status code (#{print_code(code)}) but it was 666")
    end

    class Symbol
      def articleize
        %w(a e i o u).include?(self[0].downcase) ? "an #{self}" : "a #{self}"
      end
    end

    def print_code(code)
      if code == 404
        return 404
      else
        return "#{(code.digits[0])}xx"
      end
    end
  end

  context "with success status code group" do
      include_examples "response statuses", 222, :success
  end

  context "with error status code groups" do
      include_examples "response statuses", 555, :error
  end

  context "with missing status code groups" do
      include_examples "response statuses", 404, :missing
  end

  context "with general status code group", ":redirect" do
    subject(:have_redirect_status) { have_http_status(:redirect) }

    it_behaves_like "supports different response instances" do
      subject(:matcher) { have_redirect_status }

      let(:code) { 308 }
    end

    describe "matching a response" do
      it "returns true for a response with a 3xx status code" do
        any_3xx_code = 308
        response     = create_response(:status => any_3xx_code)

        expect( have_redirect_status.matches?(response) ).to be(true)
      end

      it "returns false for a response with a different code" do
        non_redirect_code = 400
        response          = create_response(:status => non_redirect_code)

        expect( have_redirect_status.matches?(response) ).to be(false)
      end
    end

    it "describes responding with a redirect status code" do
      expect(have_redirect_status.description).
        to eq("respond with a redirect status code (3xx)")
    end

    it "has a failure message reporting the expected and actual status codes" do
      non_redirect_code = 400
      response          = create_response(:status => non_redirect_code)

      expect{ have_redirect_status.matches? response }.
        to change(have_redirect_status, :failure_message).
        to(/a redirect status code \(3xx\) but it was 400/)
    end

    it "has a negated failure message reporting the expected and actual status codes" do
      any_3xx_code = 308
      response     = create_response(:status => any_3xx_code)

      expect{ have_redirect_status.matches? response }.
        to change(have_redirect_status, :failure_message_when_negated).
        to(/not to have a redirect status code \(3xx\) but it was 308/)
    end
  end

  context "with a nil status" do
    it "raises an ArgumentError" do
      expect{ have_http_status(nil) }.to raise_error ArgumentError
    end
  end
end
