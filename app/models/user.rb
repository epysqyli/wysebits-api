class User < ApplicationRecord
  has_secure_password

  validates :name, presence: true, length: { minimum: 3 }
  validates :email_address, presence: true, length: { minimum: 4, maximum: 125 },
                            format: { with: /^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$/, multiline: true, message: 'Invalid format' }
  validates :password_confirmation, presence: true
end
