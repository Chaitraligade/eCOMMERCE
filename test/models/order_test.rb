require "test_helper"

class OrderTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      email: "test_user@example.com",
      password: "password",
      password_confirmation: "password",
      name: "Test User",  # ✅ Ensure name is provided
      address: "123 Main St"  # ✅ Ensure address is provided
    )

    @category = Category.create!(
      name: "Toys",
      description: "All toy products"  # ✅ Ensure description is provided
    )

    @product = Product.create!(
      name: "Toy Car",
      description: "A cool toy car",
      price: 10.99,
      stock: 10,
      category: @category
    )

    @order = Order.create!(
      user: @user,
      user_name: "John Doe",
      user_address: "123 Street, City",
      payment_method: "credit_card",
      status: "pending",
      total_price: 10.99  # ✅ Ensure this is set
    )

    # ✅ Ensure at least one order item exists
    @order_item = @order.order_items.create!(
      product: @product,
      quantity: 2,
      price: @product.price
    )

    @order.reload # ✅ Ensure associations are loaded
  end


  ## ✅ Presence Validations ##
  test "should be valid with all attributes" do
    assert @order.valid?
  end

  test "should require user_name" do
    @order.user_name = ""
    assert_not @order.valid?
  end

  test "should require user_address" do
    @order.user_address = ""
    assert_not @order.valid?
  end

  test "should require payment_method" do
    @order.payment_method = ""
    assert_not @order.valid?
  end

  test "should require user_id" do
    @order.user = nil
    assert_not @order.valid?
  end

  ## ✅ Numericality Validations ##
  test "should require total_price to be greater than or equal to 0.01" do
    @order.total_price = -1
    assert_not @order.valid?
  end

  ## ✅ Status Validation ##
  test "should accept valid statuses" do
    Order::STATUSES.each do |valid_status|
      @order.status = valid_status
      assert @order.valid?, "#{valid_status} should be valid"
    end
  end

  test "should reject invalid statuses" do
    @order.status = "invalid_status"
    assert_not @order.valid?
  end

  ## ✅ Callbacks ##
  test "should set default status if blank" do
    @order.status = nil
    @order.save
    assert_equal "pending", @order.status
  end

  ## ✅ Instance Methods ##
  test "should mark order as paid" do
    @order.mark_as_paid!
    assert @order.paid
    assert_equal "completed", @order.status
  end

  

  ## ✅ Class Methods ##
  test "should return correct ransackable attributes" do
    expected_attrs = ["id", "status", "total_price", "order_date", "payment_status", "user_id", "shipping_address"]
    assert_equal expected_attrs, Order.ransackable_attributes
  end

  test "should return correct ransackable associations" do
    expected_assocs = ["order_items", "products", "user"]
    assert_equal expected_assocs, Order.ransackable_associations
  end
end
