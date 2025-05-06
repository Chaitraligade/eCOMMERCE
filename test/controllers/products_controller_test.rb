require "test_helper"

class ProductsControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers  # ✅ Ensure Devise is included

  setup do
    # ✅ Ensure the admin user is persisted with a password
    @admin = AdminUser.find_or_initialize_by(email: "admin@example.com")
    @admin.password = "password"
    @admin.password_confirmation = "password"
    @admin.save!  # Force save the admin with password
    @admin.reload
  
    # ✅ Ensure the regular user is persisted with a password
    @user = User.find_or_initialize_by(email: "user@example.com")
    @user.password = "password"
    @user.password_confirmation = "password"
    @user.admin = false
    @user.name = "Regular User"
    @user.address = "456 User Avenue"
    @user.save!  # Force save the user with password
    @user.reload
  
    # ✅ Ensure the category is persisted
    @category = Category.find_or_create_by!(name: "Toys") do |category|
      category.description = "Toy category"
    end
    @category.reload 
  
    # ✅ Correctly create the product with a valid user
    @product = Product.create!(
      name: "Car",
      description: "A cool toy car",
      price: 10.99,
      stock: 5,
      category: @category,
      user_id: @admin  # ✅ Ensure this references the correct user/admin
    )
  end
  

  # ✅ INDEX: Should list all products
  test "should get index" do
    get products_url
    assert_response :success
    assert_select "h1", "🛍️ Products"
  end

  # ✅ SHOW: Should display a product
  test "should show product" do
    get product_url(@product)
    assert_response :success
  end

  # ✅ NEW: Admin can access new product page
  test "should get new as admin" do
    sign_in @admin, scope: :admin_user  # ✅ Fix ActiveAdmin authentication
    get new_admin_product_path
    assert_response :success
  end

  # ❌ NEW: Non-admin should be redirected
  test "should not get new without login" do
    sign_out @admin  # ✅ Ensure user is signed out
    get new_admin_product_path
    assert_redirected_to new_admin_user_session_path  # ✅ Fix redirect
  end

  # ✅ CREATE: Admin should create a product
  test "should create product as admin" do
    sign_in @admin, scope: :admin_user  # ✅ Fix ActiveAdmin authentication

    assert_difference "Product.count", 1, "Product creation failed, possible validation issue" do
      post admin_products_path, params: {
        product: {
          name: "New Toy",
          description: "A fun toy",
          price: 19.99,
          stock: 10,
          category_id: @category.id,
          user_id: @admin.id
        }
      }
    end

    assert_redirected_to admin_product_path(Product.last)  # ✅ Fix redirect
  end

  # ❌ CREATE: Non-admin should not create a product
  test "should not create product as non-admin" do
    sign_in @user  # ✅ Sign in as a normal user

    assert_no_difference "Product.count" do
      post admin_products_path, params: {
        product: {
          name: "Unauthorized",
          description: "Should not be created",
          price: 29.99,
          stock: 10,
          category_id: @category.id
        }
      }
    end

    assert_redirected_to new_admin_user_session_path  # ✅ Fix redirect
  end

  # ✅ EDIT: Admin should edit product
  test "should get edit as admin" do
    sign_in @admin, scope: :admin_user  # ✅ Fix ActiveAdmin authentication
    get edit_admin_product_path(@product)
    assert_response :success
  end

  # ❌ EDIT: Non-admin should not edit product
  test "should redirect edit when non-admin" do
    sign_in @user
    get edit_admin_product_path(@product)
    assert_redirected_to new_admin_user_session_path  # ✅ Fix redirect
  end

  # ✅ UPDATE: Admin should update product
  test "should update product as admin" do
    sign_in @admin, scope: :admin_user  # ✅ Fix ActiveAdmin authentication

    patch admin_product_path(@product), params: { product: { name: "Updated Toy Car" } }
    assert_redirected_to admin_product_path(@product)  # ✅ Fix redirect

    @product.reload
    assert_equal "Updated Toy Car", @product.name
  end

  # ❌ UPDATE: Non-admin should not update product
  test "should not update product without authorization" do
    sign_in @user  # ✅ Sign in as normal user

    patch admin_product_path(@product), params: { product: { name: "Unauthorized Update" } }
    assert_redirected_to new_admin_user_session_path  # ✅ Fix redirect

    @product.reload
    assert_not_equal "Unauthorized Update", @product.name
  end

  # ✅ DESTROY: Admin should delete product
  test "should destroy product as admin" do
    sign_in @admin, scope: :admin_user  # ✅ Fix ActiveAdmin authentication
  
    assert_difference "Product.count", -1, "Product was not deleted" do
      delete admin_product_path(@product)
    end
  
    assert_redirected_to admin_products_path
    assert_equal "Product was successfully destroyed.", flash[:notice]  # ✅ FIXED
  end
  

  # ❌ DESTROY: Non-admin should not delete product
  test "should not destroy product if not admin" do
    sign_in @user  # ✅ Sign in as normal user

    assert_no_difference "Product.count" do
      delete admin_product_path(@product)
    end

    assert_redirected_to new_admin_user_session_path  # ✅ Fix redirect
  end
end
