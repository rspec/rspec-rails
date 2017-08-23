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

  context "with general status code group", ":server_error" do
    # `server_error?` is part of the Rack Helpers and is defined as:
    #
    #     status >= 500 && status < 600
    #
    # See:
    #
    # - https://github.com/rack/rack/blob/ce4a3959/lib/rack/response.rb#L122
    # - https://github.com/rack/rack/blob/master/lib/rack/response.rb

    subject(:have_server_error_status) { have_http_status(:server_error) }

    it_behaves_like "supports different response instances" do
      subject(:matcher) { have_server_error_status }

      let(:code) { 555 }
    end

    describe "matching a response" do
      it "returns true for a response with a 5xx status code" do
        any_5xx_code = 555
        response     = create_response(:status => any_5xx_code)

        expect( have_server_error_status.matches?(response) ).to be(true)
      end

      it "returns false for a response with a different code" do
        client_error_code = 400
        response          = create_response(:status => client_error_code)

        expect( have_server_error_status.matches?(response) ).to be(false)
      end
    end

    it "describes responding with a server_error status code" do
      expect(have_server_error_status.description).
        to eq("respond with a server_error status code (5xx)")
    end

    it "has a failure message reporting the expected and actual status codes" do
      client_error_code = 400
      response          = create_response(:status => client_error_code)

      expect{ have_server_error_status.matches? response }.
        to change(have_server_error_status, :failure_message).
        to(/a server_error status code \(5xx\) but it was 400/)
    end

    it "has a negated failure message reporting the expected and actual status codes" do
      any_5xx_code = 555
      response     = create_response(:status => any_5xx_code)

      expect{ have_server_error_status.matches? response }.
        to change(have_server_error_status, :failure_message_when_negated).
        to(/not to have a server_error status code \(5xx\) but it was 555/)
    end
  end

  context "with general status code group", ":successful" do
    # `successful?` is part of the Rack Helpers and is defined as:
    #
    #     status >= 200 && status < 300
    #
    # See:
    #
    # - https://github.com/rack/rack/blob/ce4a3959/lib/rack/response.rb#L119
    # - https://github.com/rack/rack/blob/master/lib/rack/response.rb

    subject(:have_successful_status) { have_http_status(:successful) }

    it_behaves_like "supports different response instances" do
      subject(:matcher) { have_successful_status }

      let(:code) { 222 }
    end

    describe "matching a response" do
      it "returns true for a response with a 2xx status code" do
        any_2xx_code = 222
        response     = create_response(:status => any_2xx_code)

        expect( have_successful_status.matches?(response) ).to be(true)
      end

      it "returns false for a response with a different code" do
        non_successful_code = 400
        response            = create_response(:status => non_successful_code)

        expect( have_successful_status.matches?(response) ).to be(false)
      end
    end

    it "describes responding with a successful status code" do
      expect(have_successful_status.description).
        to eq("respond with a successful status code (2xx)")
    end

    it "has a failure message reporting the expected and actual status codes" do
      non_successful_code = 400
      response            = create_response(:status => non_successful_code)

      expect{ have_successful_status.matches? response }.
        to change(have_successful_status, :failure_message).
        to(/a successful status code \(2xx\) but it was 400/)
    end

    it "has a negated failure message reporting the expected and actual status codes" do
      any_2xx_code = 222
      response     = create_response(:status => any_2xx_code)

      expect{ have_successful_status.matches? response }.
        to change(have_successful_status, :failure_message_when_negated).
        to(/not to have a successful status code \(2xx\) but it was 222/)
    end
  end

  context "with general status code group", ":redirection" do
    # `redirection?` is part of the Rack Helpers and is defined as:
    #
    #     status >= 300 && status < 400
    #
    # See:
    #
    # - https://github.com/rack/rack/blob/ce4a3959/lib/rack/response.rb#L120
    # - https://github.com/rack/rack/blob/master/lib/rack/response.rb

    subject(:have_redirection_status) { have_http_status(:redirection) }

    it_behaves_like "supports different response instances" do
      subject(:matcher) { have_redirection_status }

      let(:code) { 308 }
    end

    describe "matching a response" do
      it "returns true for a response with a 3xx status code" do
        any_3xx_code = 308
        response     = create_response(:status => any_3xx_code)

        expect( have_redirection_status.matches?(response) ).to be(true)
      end

      it "returns false for a response with a different code" do
        non_redirection_code = 400
        response          = create_response(:status => non_redirection_code)

        expect( have_redirection_status.matches?(response) ).to be(false)
      end
    end

    it "describes responding with a redirection status code" do
      expect(have_redirection_status.description).
        to eq("respond with a redirection status code (3xx)")
    end

    it "has a failure message reporting the expected and actual status codes" do
      non_redirection_code = 400
      response          = create_response(:status => non_redirection_code)

      expect{ have_redirection_status.matches? response }.
        to change(have_redirection_status, :failure_message).
        to(/a redirection status code \(3xx\) but it was 400/)
    end

    it "has a negated failure message reporting the expected and actual status codes" do
      any_3xx_code = 308
      response     = create_response(:status => any_3xx_code)

      expect{ have_redirection_status.matches? response }.
        to change(have_redirection_status, :failure_message_when_negated).
        to(/not to have a redirection status code \(3xx\) but it was 308/)
    end
  end

  context "with general status code group", ":redirection" do
    # `redirection?` is part of the Rack Helpers and is defined as:
    #
    #     [301, 302, 303, 307, 308].include? status
    #
    # See:
    #
    # - https://github.com/rack/rack/blob/bcf2698bcc/lib/rack/response.rb#L132
    # - https://github.com/rack/rack/blob/master/lib/rack/response.rb

    subject(:have_redirect_status) { have_http_status(:redirect) }

    it_behaves_like "supports different response instances" do
      subject(:matcher) { have_redirect_status }

      let(:code) { 308 }
    end

    describe "matching a response" do
      it "returns true for a response with a 301, 302, 303, 307, 308 status code" do
        any_redirect_code = 308
        response     = create_response(:status => any_redirect_code)

        expect( have_redirect_status.matches?(response) ).to be(true)
      end

      it "returns false for a response with a different code" do
        non_redirect_code = 310
        response          = create_response(:status => non_redirect_code)

        expect( have_redirect_status.matches?(response) ).to be(false)
      end
    end

    it "describes responding with a redirect status code" do
      expect(have_redirect_status.description).
        to eq("respond with a redirect status code (301, 302, 303, 307, 308)")
    end

    it "has a failure message reporting the expected and actual status codes" do
      non_redirect_code = 310
      response          = create_response(:status => non_redirect_code)

      expect{ have_redirect_status.matches? response }.
        to change(have_redirect_status, :failure_message).
        to(/a redirect status code \(301, 302, 303, 307, 308\) but it was 310/)
    end

    it "has a negated failure message reporting the expected and actual status codes" do
      any_3xx_code = 308
      response     = create_response(:status => any_3xx_code)

      expect{ have_redirect_status.matches? response }.
        to change(have_redirect_status, :failure_message_when_negated).
        to(/not to have a redirect status code \(301, 302, 303, 307, 308\) but it was 308/)
    end
  end

  context "with a nil status" do
    it "raises an ArgumentError" do
      expect{ have_http_status(nil) }.to raise_error ArgumentError
    end
  end
end
