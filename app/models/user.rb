class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  #  has_secure_password
  has_many :cart_items
  has_many :orders
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
         validates :name, presence: true
         validates :address, presence: true
         validates :role, inclusion: { in: ['admin', 'user'] }
         

         #  before_validation :set_default_role, on: :create
         enum role: { user: 'user', admin: 'admin' }       
  
        def admin?
          role == "admin"  # Change this if your database stores roles differently
        end      

        def self.digest(string)
          BCrypt::Password.create(string)
        end
private


  
  def set_default_role
    self.role ||= "user"
  end
end
