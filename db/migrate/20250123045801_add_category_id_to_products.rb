class AddCategoryIdToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :category_id, :integer
  end
end
