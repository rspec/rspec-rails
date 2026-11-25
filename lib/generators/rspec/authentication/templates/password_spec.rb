require 'rails_helper'

RSpec.describe "Passwords", <%= type_metatag(:request) %> do
  # TODO: Replace with your factory or model creation method
  # For example, with FactoryBot: let(:user) { create(:user) }
  # or with fixtures: let(:user) { users(:one) }
  let(:user) { User.create!(email_address: "test@example.com", password: "password") }

  describe "GET /password/new" do
    it "returns http success" do
      get new_password_path
      expect(response).to have_http_status(:success)
    end
  end

  describe "POST /password" do
    it "sends password reset email for valid user" do
      expect {
        post passwords_path, params: { email_address: user.email_address }
      }.to have_enqueued_mail(PasswordsMailer, :reset).with(user)

      expect(response).to redirect_to(new_session_path)

      follow_redirect!
      expect(flash[:notice]).to eq("Password reset instructions sent (if user with that email address exists).")
    end

    it "handles invalid email gracefully" do
      expect {
        post passwords_path, params: { email_address: "missing-user@example.com" }
      }.not_to have_enqueued_mail

      expect(response).to redirect_to(new_session_path)

      follow_redirect!
      expect(flash[:notice]).to eq("Password reset instructions sent (if user with that email address exists).")
    end
  end

  describe "GET /password/edit" do
    it "returns http success with valid token" do
      get edit_password_path(user.password_reset_token)
      expect(response).to have_http_status(:success)
    end

    it "redirects with invalid password reset token" do
      get edit_password_path("invalid token")
      expect(response).to redirect_to(new_password_path)

      follow_redirect!
      expect(flash[:alert]).to eq("Password reset link is invalid or has expired.")
    end
  end

  describe "PATCH /password" do
    it "updates password with valid token and password" do
      expect {
        patch password_path(user.password_reset_token), params: { password: "new", password_confirmation: "new" }
      }.to change { user.reload.password_digest }

      expect(response).to redirect_to(new_session_path)

      follow_redirect!
      expect(flash[:notice]).to eq("Password has been reset.")
    end

    it "rejects non matching passwords" do
      token = user.password_reset_token
      expect {
        patch password_path(token), params: { password: "no", password_confirmation: "match" }
      }.not_to change { user.reload.password_digest }

      expect(response).to redirect_to(edit_password_path(token))

      follow_redirect!
      expect(flash[:alert]).to eq("Passwords did not match.")
    end
  end
end
