class AddCartIdToCartItems < ActiveRecord::Migration[7.1]
  def change
    add_column :cart_items, :cart_id, :integer
  end
end
