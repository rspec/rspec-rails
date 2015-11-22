require 'spec_helper'

RSpec.describe "have_http_status" do
  include RSpec::Rails::Matchers

  def create_response(opts = {})
    ActionDispatch::TestResponse.new(opts.fetch(:status))
  end

  shared_examples_for "supports different response instances" do
    context "given an ActionDispatch::Response" do
      it "returns true for a response with the same code" do
        response = ::ActionDispatch::Response.new(code)

        expect( matcher.matches?(response) ).to be(true)
      end
    end

    context "given an ActionDispatch::TestResponse" do
      it "returns true for a response with the same code" do
        response = ::ActionDispatch::TestResponse.new(code)

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

  context "with general status code group", ":error" do
    # The error query is an alias for `server_error?`:
    #
    # - https://github.com/rails/rails/blob/ca200378/actionpack/lib/action_dispatch/testing/test_response.rb#L27
    # - https://github.com/rails/rails/blob/master/actionpack/lib/action_dispatch/testing/test_response.rb
    #
    # `server_error?` is part of the Rack Helpers and is defined as:
    #
    #     status >= 500 && status < 600
    #
    # See:
    #
    # - https://github.com/rack/rack/blob/ce4a3959/lib/rack/response.rb#L122
    # - https://github.com/rack/rack/blob/master/lib/rack/response.rb

    subject(:have_error_status) { have_http_status(:error) }

    it_behaves_like "supports different response instances" do
      subject(:matcher) { have_error_status }

      let(:code) { 555 }
    end

    describe "matching a response" do
      it "returns true for a response with a 5xx status code" do
        any_5xx_code = 555
        response     = create_response(:status => any_5xx_code)

        expect( have_error_status.matches?(response) ).to be(true)
      end

      it "returns false for a response with a different code" do
        client_error_code = 400
        response          = create_response(:status => client_error_code)

        expect( have_error_status.matches?(response) ).to be(false)
      end
    end

    it "describes responding with an error status code" do
      expect(have_error_status.description).
        to eq("respond with an error status code (5xx)")
    end

    it "has a failure message reporting the expected and actual status codes" do
      client_error_code = 400
      response          = create_response(:status => client_error_code)

      expect{ have_error_status.matches? response }.
        to change(have_error_status, :failure_message).
        to(/an error status code \(5xx\) but it was 400/)
    end

    it "has a negated failure message reporting the expected and actual status codes" do
      any_5xx_code = 555
      response     = create_response(:status => any_5xx_code)

      expect{ have_error_status.matches? response }.
        to change(have_error_status, :failure_message_when_negated).
        to(/not to have an error status code \(5xx\) but it was 555/)
    end
  end

  context "with general status code group", ":success" do
    # The success query is an alias for `successful?`:
    #
    # - https://github.com/rails/rails/blob/ca200378/actionpack/lib/action_dispatch/testing/test_response.rb#L18
    # - https://github.com/rails/rails/blob/master/actionpack/lib/action_dispatch/testing/test_response.rb
    #
    # `successful?` is part of the Rack Helpers and is defined as:
    #
    #     status >= 200 && status < 300
    #
    # See:
    #
    # - https://github.com/rack/rack/blob/ce4a3959/lib/rack/response.rb#L119
    # - https://github.com/rack/rack/blob/master/lib/rack/response.rb

    subject(:have_success_status) { have_http_status(:success) }

    it_behaves_like "supports different response instances" do
      subject(:matcher) { have_success_status }

      let(:code) { 222 }
    end

    describe "matching a response" do
      it "returns true for a response with a 2xx status code" do
        any_2xx_code = 222
        response     = create_response(:status => any_2xx_code)

        expect( have_success_status.matches?(response) ).to be(true)
      end

      it "returns false for a response with a different code" do
        non_success_code = 400
        response         = create_response(:status => non_success_code)

        expect( have_success_status.matches?(response) ).to be(false)
      end
    end

    it "describes responding with a success status code" do
      expect(have_success_status.description).
        to eq("respond with a success status code (2xx)")
    end

    it "has a failure message reporting the expected and actual status codes" do
      non_success_code = 400
      response         = create_response(:status => non_success_code)

      expect{ have_success_status.matches? response }.
        to change(have_success_status, :failure_message).
        to(/a success status code \(2xx\) but it was 400/)
    end

    it "has a negated failure message reporting the expected and actual status codes" do
      any_2xx_code = 222
      response     = create_response(:status => any_2xx_code)

      expect{ have_success_status.matches? response }.
        to change(have_success_status, :failure_message_when_negated).
        to(/not to have a success status code \(2xx\) but it was 222/)
    end
  end

  context "with general status code group", ":missing" do
    # The missing query is an alias for `not_found?`:
    #
    # - https://github.com/rails/rails/blob/ca200378/actionpack/lib/action_dispatch/testing/test_response.rb#L21
    # - https://github.com/rails/rails/blob/master/actionpack/lib/action_dispatch/testing/test_response.rb
    #
    # `not_found?` is part of the Rack Helpers and is defined as:
    #
    #     status == 404
    #
    # See:
    #
    # - https://github.com/rack/rack/blob/ce4a3959/lib/rack/response.rb#L130
    # - https://github.com/rack/rack/blob/master/lib/rack/response.rb

    subject(:have_missing_status) { have_http_status(:missing) }

    it_behaves_like "supports different response instances" do
      subject(:matcher) { have_missing_status }

      let(:code) { 404 }
    end

    describe "matching a response" do
      it "returns true for a response with a 404 status code" do
        not_found_status = 404
        response         = create_response(:status => not_found_status)

        expect( have_missing_status.matches?(response) ).to be(true)
      end

      it "returns false for a response with a different code" do
        non_missing_status = 400
        response           = create_response(:status => non_missing_status)

        expect( have_missing_status.matches?(response) ).to be(false)
      end
    end

    it "describes responding with a missing status code" do
      expect(have_missing_status.description).
        to eq("respond with a missing status code (404)")
    end

    it "has a failure message reporting the expected and actual status codes" do
      non_missing_status = 400
      response           = create_response(:status => non_missing_status)

      expect{ have_missing_status.matches? response }.
        to change(have_missing_status, :failure_message).
        to(/a missing status code \(404\) but it was 400/)
    end

    it "has a negated failure message reporting the expected status code" do
      not_found_status = 404
      response         = create_response(:status => not_found_status)

      expect{ have_missing_status.matches? response }.
        to change(have_missing_status, :failure_message_when_negated).
        to(/not to have a missing status code \(404\) but it was 404/)
    end
  end

  context "with general status code group", ":redirect" do
    # The redirect query is an alias for `redirection?`:
    #
    # - https://github.com/rails/rails/blob/ca200378/actionpack/lib/action_dispatch/testing/test_response.rb#L24
    # - https://github.com/rails/rails/blob/master/actionpack/lib/action_dispatch/testing/test_response.rb
    #
    # `redirection?` is part of the Rack Helpers and is defined as:
    #
    #     status >= 300 && status < 400
    #
    # See:
    #
    # - https://github.com/rack/rack/blob/ce4a3959/lib/rack/response.rb#L120
    # - https://github.com/rack/rack/blob/master/lib/rack/response.rb

    subject(:have_redirect_status) { have_http_status(:redirect) }

    it_behaves_like "supports different response instances" do
      subject(:matcher) { have_redirect_status }

      let(:code) { 333 }
    end

    describe "matching a response" do
      it "returns true for a response with a 3xx status code" do
        any_3xx_code = 333
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
      any_3xx_code = 333
      response     = create_response(:status => any_3xx_code)

      expect{ have_redirect_status.matches? response }.
        to change(have_redirect_status, :failure_message_when_negated).
        to(/not to have a redirect status code \(3xx\) but it was 333/)
    end
  end

  context "with a nil status" do
    it "raises an ArgumentError" do
      expect{ have_http_status(nil) }.to raise_error ArgumentError
    end
  end

end
