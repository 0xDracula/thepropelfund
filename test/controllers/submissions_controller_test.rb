require "test_helper"

class SubmissionsControllerTest < ActionDispatch::IntegrationTest
  setup do
    OmniAuth.config.test_mode = true
  end

  teardown do
    OmniAuth.config.test_mode = false
    OmniAuth.config.mock_auth[:hackclub] = nil
  end

  test "requires sign-in to view the form" do
    get submit_path

    assert_redirected_to login_path
  end

  test "requires sign-in to submit" do
    post submit_path, params: { submission: valid_params }

    assert_redirected_to login_path
  end

  test "signed-in applicant sees the form prefilled with their email" do
    sign_in(email: "teen@example.com")

    get submit_path

    assert_response :success
    assert_select "p", text: "teen@example.com"
  end

  test "missing required field re-renders the form with errors" do
    sign_in(email: "teen@example.com")

    post submit_path, params: { submission: valid_params.merge(legal_first_name: "") }

    assert_response :unprocessable_entity
    assert_select ".form-errors"
  end

  test "valid submission redirects to the thanks page" do
    sign_in(email: "teen@example.com")

    post submit_path, params: { submission: valid_params }

    assert_redirected_to submit_thanks_path
  end

  private

  def valid_params
    {
      legal_first_name: "Ada",
      legal_last_name: "Lovelace",
      project_description: "A synth I'm building from scratch.",
      policy_confirmed: "1"
    }
  end

  def sign_in(email:)
    OmniAuth.config.mock_auth[:hackclub] = OmniAuth::AuthHash.new(
      provider: "hackclub",
      uid: "ident!U123",
      info: { name: "Test Teen", email: email },
      extra: { raw_info: { "slack_id" => "U123", "verification_status" => "verified", "ysws_eligible" => true } }
    )
    get "/auth/callback"
  end
end
