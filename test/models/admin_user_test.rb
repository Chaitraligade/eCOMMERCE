require "test_helper"

class AdminUserTest < ActiveSupport::TestCase
  # test "the truth" do
  #   assert true
  # end

  def setup
    @admin_user = AdminUser.new(
      email: "admin@example.com",
      password: "securepassword",
      password_confirmation: "securepassword"
    )
  end

  # ✅ Test: Should be valid with correct attributes
  test "should be valid with valid attributes" do
    assert @admin_user.valid?
  end

  # ✅ Test: Email should be present
  test "should not be valid without an email" do
    @admin_user.email = ""
    assert_not @admin_user.valid?, "Saved admin user without an email"
  end

  # ✅ Test: Password should be present
  test "should not be valid without a password" do
    @admin_user.password = ""
    @admin_user.password_confirmation = ""
    assert_not @admin_user.valid?, "Saved admin user without a password"
  end

  # ✅ Test: Email should be unique
  test "should not allow duplicate emails" do
    @admin_user.save!
    duplicate_admin = @admin_user.dup
    duplicate_admin.email = @admin_user.email.upcase # Case insensitive check
    assert_not duplicate_admin.valid?, "Allowed duplicate email registration"
  end

  # ✅ Test: Devise authentication should work
  test "should authenticate with correct password" do
    @admin_user.save!
    assert AdminUser.find_by(email: "admin@example.com").valid_password?("securepassword"),
           "Admin user authentication failed"
  end

  # ✅ Test: Ransackable attributes should return the allowed attributes
  test "ransackable attributes should return correct list" do
    expected_attributes = ["created_at", "email", "remember_created_at", "reset_password_sent_at", "updated_at"]
    assert_equal expected_attributes, AdminUser.ransackable_attributes
  end
end
