class AddPaymentMethodToUsers < ActiveRecord::Migration[7.1]
  def change
    add_column :users, :payment_method, :string
  end
end
