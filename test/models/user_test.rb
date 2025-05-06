require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      name: "John Doe",
      email: "user_#{SecureRandom.hex(4)}@example.com",
      password: "password",
      address: "123 Main St"
    )
  end
  

  test "should be valid with all attributes" do
    assert @user.valid?
  end

  test "should require a name" do
    @user.name = ""
    assert_not @user.valid?
    assert_includes @user.errors[:name], "can't be blank"
  end

  test "should require an address" do
    @user.address = ""
    assert_not @user.valid?
    assert_includes @user.errors[:address], "can't be blank"
  end

  test "should require a valid role" do
    assert_raises(ArgumentError) do
      @user.update!(role: "invalid_role") # 🚀 This will now correctly raise an error
    end
  end
  
  test "should default role to user if not set" do
    user_without_role = User.new(
      name: "Jane Doe",
      address: "456 Another St",
      email: "jane@example.com",
      password: "password",
      password_confirmation: "password"
    )
    user_without_role.valid?
    assert_equal "user", user_without_role.role
  end

  test "admin? should return true for admin role" do
    @user.role = "admin"
    assert @user.admin?
  end

  test "admin? should return false for user role" do
    @user.role = "user"
    assert_not @user.admin?
  end

  test "digest should create a hashed password" do
    password_digest = User.digest("password")
    assert BCrypt::Password.new(password_digest).is_password?("password")
  end
end
