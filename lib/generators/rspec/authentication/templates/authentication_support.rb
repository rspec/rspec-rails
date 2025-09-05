module AuthenticationSupport
  # Helper method to sign in a user for testing purposes
  # Uses the actual authentication flow via POST request
  def sign_in_as(user)
    post session_path, params: {
      email_address: user.email_address,
      password: "password"
    }
  end
end
