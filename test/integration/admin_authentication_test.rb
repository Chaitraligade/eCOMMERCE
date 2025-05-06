require "test_helper"

class AdminAuthenticationTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers # Required for sign_in to work

  test "admin should be able to sign in" do
    admin = User.find_or_create_by!(email: "admin@example.com") do |user|
      user.password = "password"
      user.password_confirmation = "password"
      user.admin = true
      user.name = "Admin User"
      user.address = "123 Admin Street"
    end

    puts "DEBUG: Admin User - #{admin.inspect}" # Print admin user info

    # Make sure the user is valid before trying to log in
    assert admin.valid?, "Admin should be a valid user"

    # Attempt to log in
    post user_session_path, params: { user: { email: admin.email, password: "password" } }
    follow_redirect!

    puts "DEBUG: Response Body - #{response.body}" # Check if login succeeded

    assert_response :success, "Login request did not succeed"
    assert admin.reload.admin?, "Admin should have admin privileges"
  end
end

