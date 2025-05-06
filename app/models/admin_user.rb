class AdminUser < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable


    def self.ransackable_attributes(auth_object = nil)
          # List the attributes you want to allow for search/filter
      ["created_at", "email", "remember_created_at", "reset_password_sent_at", "updated_at"]
    end
      
end
