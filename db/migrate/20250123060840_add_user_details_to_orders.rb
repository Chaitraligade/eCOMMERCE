class AddUserDetailsToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :user_name, :string
    add_column :orders, :user_email, :string
    add_column :orders, :user_address, :text
    add_column :orders, :payment_method, :string
  end
end
