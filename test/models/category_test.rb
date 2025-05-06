require "test_helper"

class CategoryTest < ActiveSupport::TestCase
  def setup
    @category = Category.create!(
      name: "Toys",
      description: "Various kinds of toys"
    )

    @product = Product.create!(
      name: "Toy Car",
      description: "A cool toy car",
      price: 10.99,
      stock: 5,
      category: @category  # ✅ Correctly associate product with category
    )
  end

  ## ✅ Presence & Uniqueness Validations ##
  
  test "should be valid with valid attributes" do
    assert @category.valid?, "Category should be valid"
  end

  test "should require a name" do
    @category.name = nil
    assert_not @category.valid?, "Category should be invalid without a name"
    assert_includes @category.errors[:name], "can't be blank"
  end

  test "should require a description" do
    @category.description = nil
    assert_not @category.valid?, "Category should be invalid without a description"
    assert_includes @category.errors[:description], "can't be blank"
  end

  test "should enforce unique category name" do
    duplicate_category = Category.new(name: "Toys", description: "Duplicate category")
    assert_not duplicate_category.valid?, "Duplicate category name should be invalid"
    assert_includes duplicate_category.errors[:name], "has already been taken"
  end

  ## ✅ Association Tests ##
  
  test "should have many products" do
    assert_respond_to @category, :products
    assert_equal 1, @category.products.count
    assert_includes @category.products, @product
  end

  ## ✅ Ransackable Attributes & Associations ##
  
  test "should return correct ransackable attributes" do
    expected_attributes = ["created_at", "description", "id", "id_value", "name", "updated_at"]
    assert_equal expected_attributes, Category.ransackable_attributes
  end

  test "should return correct ransackable associations" do
    assert_equal ["products"], Category.ransackable_associations
  end
end
