class Cart < ApplicationRecord
  has_many :cart_items, dependent: :destroy
  has_many :products, through: :cart_items
  belongs_to :user
  has_many :cart_items
  # Add a method to calculate the total cost of the cart
  def total_price
    cart_items.joins(:product).sum("cart_items.quantity * products.price")
  end
end
