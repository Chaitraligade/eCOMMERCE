require "test_helper"
require "action_dispatch/testing/test_process"

class ProductTest < ActiveSupport::TestCase
  include ActionDispatch::TestProcess 

  def setup
    @category = Category.create(name: "Toys", description: "my toy")
    @category = Category.first || Category.create!(name: "Toys")
    @product = Product.new(
      name: "Toy Car",
      description: "A cool toy car",
      price: 10.99,
      stock: 5,
      category: @category,
      image: Rack::Test::UploadedFile.new(Rails.root.join("test/fixtures/files/sample_image.jpg"), "image/jpeg")
    )
  end

  # ✅ Test Valid Product
  test "should be valid with all attributes" do
    assert @product.valid?
  end

  # 🚨 Validations 🚨
  test "should require a name" do
    @product.name = nil
    assert_not @product.valid?
    assert_includes @product.errors[:name], "can't be blank"
  end

  test "should require a description" do
    @product.description = nil
    assert_not @product.valid?
    assert_includes @product.errors[:description], "can't be blank"
  end

  test "should require a category" do
    @product.category = nil
    assert_not @product.valid?
    assert_includes @product.errors[:category_id], "can't be blank"
  end

  test "should not allow negative price" do
    @product.price = -1
    assert_not @product.valid?
    assert_includes @product.errors[:price], "must be greater than or equal to 0"
  end

  test "should not allow negative stock" do
    @product.stock = -5
    assert_not @product.valid?
    assert_includes @product.errors[:stock], "must be greater than or equal to 0"
  end

  test "should only allow integer stock values" do
    @product.stock = 3.5
    assert_not @product.valid?
    assert_includes @product.errors[:stock], "must be an integer"
  end

  # 🔍 Testing Associations 🔍
  test "should belong to a category" do
    assert_equal @category, @product.category
  end

  # 🔎 Testing Search Scope 🔎
  test "should return products that match the search term" do
    @product.save!
    result = Product.search_by_name_and_description("Car")
    assert_includes result, @product
  end

  test "should not return products that do not match the search term" do
    @product.save!
    result = Product.search_by_name_and_description("Doll")
    assert_not_includes result, @product
  end

  # 📸 Image Validation Tests 📸
  test "should allow valid image types" do
    valid_image = fixture_file_upload("test/fixtures/files/sample_image.jpg", "image/jpeg")
    @product.image.attach(valid_image)
    assert @product.valid?
  end

  test "should reject invalid image types" do
    invalid_image = fixture_file_upload("test/fixtures/files/sample.txt", "text/plain")
    @product.image.attach(invalid_image)
    assert_not @product.valid?
    assert_includes @product.errors[:image], "must be a JPEG, PNG, or WEBP file."
  end

  test "should reject oversized images" do
    large_image = fixture_file_upload("test/fixtures/files/large_image.jpg", "image/jpeg")
    @product.image.attach(large_image)
    @product.image.byte_size = 6.megabytes # Simulating large image
    assert_not @product.valid?
    assert_includes @product.errors[:image], "is too large. Maximum size is 5MB."
  end
end
