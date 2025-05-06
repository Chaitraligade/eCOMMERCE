ENV['RAILS_ENV'] ||= 'test'
require_relative "../config/environment"
require "rails/test_help"
require "database_cleaner/active_record"
self.use_transactional_tests = true

DatabaseCleaner.strategy = :transaction

class ActiveSupport::TestCase
  include Devise::Test::IntegrationHelpers
  setup { DatabaseCleaner.start }
  teardown { DatabaseCleaner.clean }
  
  
  setup do
    @controller.class.skip_forgery_protection = true
  end
  
  def sign_in_as(user)
    post login_url, params: { email: user.email, password: "password" }  # Ensure correct login params
  end
  
  
  test "should get index" do
    get products_url
    assert_response :success
    assert_select 'title', 'Products'
  end

  # Test show action
  test "should show product" do
    product = products(:one) # Assuming fixtures are used
    get product_url(product)
    assert_response :success
    assert_select 'h1', product.name
  end

  # Test create action
  test "should create product" do
    assert_difference('Product.count') do
      post products_url, params: { product: { name: 'Smartphone', price: 500.0, category: 'Electronics' } }
    end
    assert_redirected_to product_url(Product.last)
  end

end
