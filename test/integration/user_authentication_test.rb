require "test_helper"

class UserAuthenticationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers  # ✅ Devise test helpers

  def setup
    @user = User.create!(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "user can sign up" do
    get new_user_registration_path  # ✅ Go to sign-up page
    assert_response :success

    assert_difference("User.count", 1) do
      post user_registration_path, params: { user: {
        email: "newuser@example.com",
        password: "password123",
        password_confirmation: "password123"
      } }
    end

    assert_redirected_to root_path  # ✅ Change to correct post-sign-up path
  end

  test "user can sign in" do
    get new_user_session_path  # ✅ Go to login page
    assert_response :success

    post user_session_path, params: { user: {
      email: @user.email,
      password: "password123"
    } }
    assert_redirected_to root_path  # ✅ Change if redirect is different

    follow_redirect!
    assert_match "Signed in successfully", response.body  # ✅ Flash message check
  end

  test "user can sign out" do
    sign_in @user
    delete destroy_user_session_path
    assert_redirected_to root_path  # ✅ Change based on your config
    follow_redirect!
    assert_match "Signed out successfully", response.body  # ✅ Flash message check
  end
end
