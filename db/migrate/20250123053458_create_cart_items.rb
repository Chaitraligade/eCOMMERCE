class CreateCartItems < ActiveRecord::Migration[7.1]
  def change
    create_table :cart_items do |t|
      t.integer :product_id
      t.integer :quantity
      t.references :user, null: false, foreign_key: true
      t.timestamps
    end
  end
end
