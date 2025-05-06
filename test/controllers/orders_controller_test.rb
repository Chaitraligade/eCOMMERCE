require "test_helper"

class OrdersControllerTest < ActionDispatch::IntegrationTest
  include Devise::Test::IntegrationHelpers # Required for authentication

  setup do
    @admin = User.find_or_create_by!(email: "admin@example.com") do |user|
      user.password = "password"
      user.password_confirmation = "password"
      user.admin = true
      user.name = "Admin User"
      user.address = "123 Admin Street"
    end
  
    @user = User.find_or_create_by!(email: "user@example.com") do |user|
      user.password = "password"
      user.password_confirmation = "password"
      user.admin = false
      user.name = "Regular User"
      user.address = "456 User Avenue"
    end
  
    @category = Category.find_or_create_by!(name: "Toys", description: "My toys")
  
    @product = Product.find_or_create_by!(name: "Toy Car") do |product|
      product.description = "A cool toy car"
      product.price = 10.99
      product.stock = 5
      product.category = @category
      product.user_id = @admin.id
    end
  
    sign_in @user # Ensure the user is signed in
    # session[:cart] = {} # Initialize cart
  end
  

  # ✅ INDEX: Should list all orders for signed-in user
  test "should get index if user is signed in" do
    get orders_path
    assert_response :success
  end

  test "should redirect from index if user is not signed in" do
    sign_out @user
    get orders_path
    assert_redirected_to new_user_session_path
  end

  # ✅ NEW ORDER FORM
  test "should get new order form" do
    get new_order_path
    assert_response :success
  end

  # ✅ SHOW ORDER
  test "should show order" do
    order = Order.create!(
      user: @user,
      user_name: "John Doe",
      user_address: "123 Street",
      payment_method: "COD",
      total_price: 100.0,
      status: "pending"
    )

    get order_path(order)
    assert_response :success
  end

  test "should not show another user's order" do
    other_order = Order.create!(
      user: @admin,
      user_name: "Admin",
      user_address: "Admin Street",
      payment_method: "COD",
      total_price: 50.0,
      status: "pending"
    )

    get order_path(other_order)
    assert_redirected_to orders_path
    assert_equal "Order not found.", flash[:alert]
  end

  # ✅ CART FUNCTIONALITY
  test "should add product to cart" do
    post add_to_cart_orders_orders_path, params: { product_id: @product.id }
    assert_redirected_to cart_orders_orders_path
    assert_equal "Product added to cart!", flash[:notice]
    assert session[:cart].present?
  end

  test "should remove product from cart" do
    post add_to_cart_orders_orders_path, params: { product_id: @product.id }  # Ensure cart is initialized
    delete remove_from_cart_orders_orders_path, params: { product_id: @product.id }
    assert_redirected_to cart_orders_orders_path
    assert_equal "Product removed from cart.", flash[:notice]
  end

  test "should not remove non-existent product from cart" do
    delete remove_from_cart_orders_orders_path, params: { product_id: 99999 }
    assert_redirected_to cart_orders_orders_path
    assert_equal "Product not found in cart.", flash[:alert]
  end

  # ✅ ORDER CREATION
  test "should create order from cart" do
    post add_to_cart_orders_orders_path, params: { product_id: @product.id }
    follow_redirect!
  
    Rails.logger.debug "🔍 Test Cart Contents Before Order: #{session[:cart].inspect}"
  
    assert session[:cart].present?, "Cart should not be empty"
    assert_equal 1, session[:cart][@product.id.to_s], "Cart should contain 1 item"
  
    assert_difference "Order.count", 1, "Order was not created!" do
      post orders_path, params: { order: { 
        user_name: "John Doe", 
        user_address: "123 Main St",
        payment_method: "COD"
      } }
    end
  
    order = Order.last
    Rails.logger.debug "🚀 Created Order: #{order.inspect}"
  
    assert order.total_price.positive?, "Total price should be greater than zero"
    assert_redirected_to thank_you_order_path(order)
  end
  
  
  

  test "should not create order if cart is empty" do
    assert_no_difference "Order.count" do
      post orders_path, params: { order: { user_name: "John Doe", user_address: "123 Street", payment_method: "COD" } }
    end

    assert_redirected_to root_path
    assert_equal "Your cart is empty!", flash[:alert]
  end

  # ✅ CHECKOUT
  test "should get checkout page" do
    get checkout_orders_path
    assert_response :success
  end
end
