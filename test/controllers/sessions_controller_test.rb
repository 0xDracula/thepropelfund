require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    OmniAuth.config.test_mode = true
  end

  teardown do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:hackclub] = nil
  end

  test "signing in populates the session with identity claims" do
    mock_hca_auth(slack_id: "U123", name: "Test Teen", email: "teen@example.com")

    get "/auth/callback"

    assert_redirected_to login_path
    assert_equal "U123", session[:identity][:slack_id]
    assert_equal "Test Teen", session[:identity][:name]
    assert_equal "teen@example.com", session[:identity][:email]
  end

  test "logout clears the session" do
    mock_hca_auth(slack_id: "U123", name: "Test Teen", email: "teen@example.com")
    get "/auth/callback"
    assert session[:identity].present?

    delete "/logout"

    assert_redirected_to login_path
    assert_nil session[:identity]
  end

  test "failure page renders the omniauth error message" do
    get "/auth/failure", params: { message: "invalid_credentials" }

    assert_response :success
    assert_match "invalid_credentials", response.body
  end

  private

  def mock_hca_auth(slack_id:, name:, email:)
    OmniAuth.config.mock_auth[:hackclub] = OmniAuth::AuthHash.new(
      provider: "hackclub",
      uid: "ident!#{slack_id}",
      info: { name: name, email: email },
      extra: { raw_info: { "slack_id" => slack_id, "verification_status" => "verified", "ysws_eligible" => true } }
    )
  end
end
