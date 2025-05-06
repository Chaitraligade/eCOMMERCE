ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"

module ActiveSupport
  # include Devise::Test::IntegrationHelpers
  class TestCase
    # Run tests in parallel with specified workers
    include Devise::Test::IntegrationHelpers
    parallelize(workers: :number_of_processors)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    # fixtures :all
    Rails.application.routes.default_url_options[:host] = 'http://www.example.com'

    # Add more helper methods to be used by all tests here...
    def sign_in_admin(user)
      sign_in user  # ✅ Devise handles admin authentication directly
    end
  end
end
