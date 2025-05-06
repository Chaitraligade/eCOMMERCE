require "test_helper"

class CategoriesControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers

  setup do
    @admin = AdminUser.create!(  # ✅ Use AdminUser for ActiveAdmin
      email: "admin@example.com",
      password: "password"
    )

    @user = User.create!(
      email: "myuser@example.com",
      password: "password",
      admin: false,
      name: "Regular User",
      address: "456 User Avenue"
    )

    @category = Category.create!(
      name: "Electronics",
      description: "Gadgets and devices"
    )
  end

  # ✅ Admin should access new category page
  test "should get new for admin" do
    sign_in @admin, scope: :admin_user  # ✅ Fix ActiveAdmin authentication
    get new_admin_category_path
    assert_response :success
  end

  # ❌ Non-admin should not access new category page
  test "should redirect new when non-admin" do
    sign_in @user
    get new_admin_category_path
    assert_redirected_to new_admin_user_session_path  # ✅ Fix redirect path
  end

  # ✅ Admin should create category
  test "should create category as admin" do
    sign_in @admin, scope: :admin_user  # ✅ Fix ActiveAdmin authentication
    assert_difference "Category.count", 1 do
      post admin_categories_path, params: { category: { name: "Books", description: "Fiction & Non-fiction" } }
    end
    assert_redirected_to admin_category_path(Category.last)  # ✅ Fix Redirect
  end

  # ❌ Non-admin should not create category
  test "should not create category as non-admin" do
    sign_in @user
    assert_no_difference "Category.count" do
      post admin_categories_path, params: { category: { name: "Unauthorized", description: "Should not be created" } }
    end
    assert_redirected_to new_admin_user_session_path  # ✅ Fix redirect
  end

  # ✅ Admin should edit category
  test "should get edit as admin" do
    sign_in @admin, scope: :admin_user  # ✅ Fix ActiveAdmin authentication
    get edit_admin_category_path(@category)
    assert_response :success
  end

  # ❌ Non-admin should not edit category
  test "should redirect edit when non-admin" do
    sign_in @user
    get edit_admin_category_path(@category)
    assert_redirected_to new_admin_user_session_path  # ✅ Fix redirect
  end

  # ✅ Admin should update category
  test "should update category as admin" do
    sign_in @admin, scope: :admin_user  # ✅ Fix ActiveAdmin authentication
    patch admin_category_path(@category), params: { category: { name: "Updated Category" } }
    assert_redirected_to admin_category_path(@category)
    @category.reload
    assert_equal "Updated Category", @category.name
  end

  # ❌ Non-admin should not update category
  test "should not update category as non-admin" do
    sign_in @user
    patch admin_category_path(@category), params: { category: { name: "Unauthorized Update" } }
    assert_redirected_to new_admin_user_session_path  # ✅ Fix redirect
    @category.reload
    assert_not_equal "Unauthorized Update", @category.name
  end

  # ✅ Admin should delete category
  test "should destroy category as admin" do
    sign_in @admin, scope: :admin_user  # ✅ Fix ActiveAdmin authentication
    assert_difference "Category.count", -1 do
      delete admin_category_path(@category)
    end
    assert_redirected_to admin_categories_path
  end

  # ❌ Non-admin should not delete category
  test "should not destroy category as non-admin" do
    sign_in @user
    assert_no_difference "Category.count" do
      delete admin_category_path(@category)
    end
    assert_redirected_to new_admin_user_session_path  # ✅ Fix redirect
  end
end

