class Product < ApplicationRecord
  belongs_to :category
  has_one_attached :image
  has_many :order_items, dependent: :destroy
  has_many :orders, through: :order_items
  has_many :cart_items
  has_many :carts, through: :cart_items
  validates :name, presence: true
  validates :description, presence: true
  validates :price, numericality: { greater_than_or_equal_to: 0 }
  validates :stock, numericality: { only_integer: true, greater_than_or_equal_to: 0 }
  validates :category_id, presence: true
  validate :acceptable_image

  include PgSearch::Model

  # This will create a search scope that looks for the provided terms in the specified fields.
  pg_search_scope :search_by_name_and_description,
    against: [:name, :description],
    using: {
      tsearch: { prefix: true }  # tsearch allows for prefix matching (e.g., search for "Tab" will also match "Tablet")
    }

  def self.ransackable_attributes(auth_object = nil)
    ["category_id", "created_at", "description", "id", "name", "price", "stock", "updated_at"]
  end

  # Allowlisting searchable associations
  def self.ransackable_associations(auth_object = nil)
    ["categories"]
  end

  private
  
  def resize_image
    return unless image.attached?

    image.variant(resize_to_limit: [300, 300]).processed
  end
 
  def acceptable_image
    return unless image.attached?

    # Check file size (less than 5MB)
    if image.byte_size > 5.megabytes
      errors.add(:image, "is too large. Maximum size is 5MB.")
    end

    # Check file type
    acceptable_types = ["image/jpeg", "image/png", "image/webp"]
    unless acceptable_types.include?(image.content_type)
      errors.add(:image, "must be a JPEG, PNG, or WEBP file.")
    end
  end
end
