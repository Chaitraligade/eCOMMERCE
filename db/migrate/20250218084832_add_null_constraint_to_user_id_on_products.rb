class AddNullConstraintToUserIdOnProducts < ActiveRecord::Migration[7.1]
  def change
    change_column_null :products, :user_id, true
  end
end
