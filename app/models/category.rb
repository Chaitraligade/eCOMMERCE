class Category < ApplicationRecord
  has_many :products, dependent: :destroy
  # has_and_belongs_to_many :products, join_table: 'categories_products'
  validates :name, presence: true, uniqueness: true
  validates :description, presence: true
  
  def self.ransackable_attributes(auth_object = nil)
    ["created_at", "description", "id", "id_value", "name", "updated_at"]  # List only the associations that should be searchable
  end

  def self.ransackable_associations(auth_object = nil)
    ["products"]
  end

end
