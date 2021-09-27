class User < ApplicationRecord
  has_secure_password

  has_many :book_tiles
  has_many :comments

  has_many :active_relationships, class_name: 'Relationship', foreign_key: 'follower_id', dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed

  has_many :passive_relationships, class_name: 'Relationship', foreign_key: 'followed_id', dependent: :destroy
  has_many :followers, through: :passive_relationships

  validates :name, presence: true, length: { minimum: 3 }
  validates :email_address, presence: true, length: { minimum: 4, maximum: 125 },
                            format: { with: /^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$/, multiline: true, message: 'Invalid format' }
  validates :password_confirmation, presence: true

  def follow(other_user)
    return if following.include?(other_user)

    following << other_user
  end

  def unfollow(other_user)
    return unless following.include?(other_user)

    following.delete(other_user)
  end
end
