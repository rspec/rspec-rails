require 'rails_helper'

RSpec.describe "Sessions", <%= type_metatag(:request) %> do
  fixtures :users

  let(:user) { users(:one) }

  describe "GET /new_session" do
    it "returns http success" do
      get new_session_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /session" do
    context "with valid credentials" do
      it "redirects to root path and sets session cookie" do
        post session_path, params: { email_address: user.email_address, password: "password" }

        expect(response).to redirect_to(root_path)
        expect(cookies[:session_id]).to be_present
      end
    end

    context "with invalid credentials" do
      it "redirects to new session path and does not set session cookie" do
        post session_path, params: { email_address: user.email_address, password: "wrong" }

        expect(response).to redirect_to(new_session_path)
        expect(cookies[:session_id]).to be_nil
      end
    end
  end

  describe "DELETE /session" do
    it "logs out the current user and redirects to new session path" do
      # Simulate being signed in
      sign_in_as(user)

      delete session_path

      expect(response).to redirect_to(new_session_path)
      expect(cookies[:session_id]).to be_empty
    end
  end

  private

  def sign_in_as(user)
    # Helper method to simulate user sign in
    # Create a real session and set the cookie using Rails cookie signing
    session = user.sessions.create!(user_agent: "test", ip_address: "127.0.0.1")
    # Manually sign the cookie value using Rails' message verifier
    signed_value = Rails.application.message_verifier('signed cookie').generate(session.id)
    cookies[:session_id] = signed_value
  end
end
