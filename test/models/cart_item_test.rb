require "test_helper"

class CartItemTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(
      name: "John Doe",
      email: "john@example.com",
      password: "password",
      address: "123 Main St"
    )

    @category = Category.create!(name: "Toys", description: "All toys")

    @product = Product.create!(
      name: "Toy Car",
      description: "Toyyyyy",
      price: 10.00,
      stock: 20,
      category: @category
    )

    @cart_item = CartItem.new(user: @user, product: @product, quantity: 2)
  end

  test "should be valid with valid attributes" do
    assert @cart_item.valid?, @cart_item.errors.full_messages.join(", ")
  end
  
  test "should not be valid without a user" do
    @cart_item.user = nil
    assert_not @cart_item.valid?, "CartItem should be invalid without a user"
  end

  test "should not be valid without a product" do
    @cart_item.product = nil
    assert_not @cart_item.valid?, "CartItem should be invalid without a product"
  end

  test "should not allow zero or negative quantity" do
    @cart_item.quantity = 0
    assert_not @cart_item.valid?, "CartItem should be invalid with zero quantity"

    @cart_item.quantity = -5
    assert_not @cart_item.valid?, "CartItem should be invalid with negative quantity"
  end
end
