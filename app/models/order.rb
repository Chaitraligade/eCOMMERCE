class Order < ApplicationRecord
  belongs_to :user, optional: true
  has_many :order_items, dependent: :destroy
  has_many :products, through: :order_items
  validates :user_name, :user_address, :payment_method, presence: true
  validates :total_price, numericality: { greater_than_or_equal_to: 0.01 }
  validates :payment_method, presence: true
  validates :user_id, presence: true
  # before_validation :calculate_total_price, if: -> { total_price.nil? || total_price.zero? }
  STATUSES = ["pending", "confirmed", "completed", "shipped", "canceled"]

  validates :status, inclusion: { in: STATUSES }

  before_validation :set_default_status

  # before_save :set_default_status
  # before_save :calculate_total_price
  def mark_as_paid!
    update(paid: true, status: 'completed')
  end

  def set_default_status
    self.status = "pending" if status.blank?
  end

  def self.ransackable_attributes(auth_object = nil)
    ["id", "status", "total_price", "order_date", "payment_status", "user_id", "shipping_address"]
  end

  def self.ransackable_associations(auth_object = nil)
    # Include the list of attributes that should be searchable
    ["order_items", "products", "user"]
  end


end
