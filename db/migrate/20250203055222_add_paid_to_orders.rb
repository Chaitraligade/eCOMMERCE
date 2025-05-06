class AddPaidToOrders < ActiveRecord::Migration[7.1]
  def change
    add_column :orders, :paid, :boolean, default: false
  end
end
