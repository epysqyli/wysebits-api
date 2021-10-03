class User < ApplicationRecord
  before_save :downcase_email
  before_create :generate_confirmation_instructions

  has_secure_password

  # associations
  has_many :book_tiles
  has_many :comments

  has_many :active_relationships, class_name: 'Relationship', foreign_key: 'follower_id', dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed

  has_many :passive_relationships, class_name: 'Relationship', foreign_key: 'followed_id', dependent: :destroy
  has_many :followers, through: :passive_relationships

  # validations
  validates :email_address, presence: true, uniqueness: true, length: { minimum: 4, maximum: 125 },
                            format: { with: /^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$/, multiline: true, message: 'Invalid format' }

  validates :password, presence: true
  validates :password_confirmation, presence: true

  # model methods
  def follow(other_user)
    return if following.include?(other_user)

    following << other_user
  end

  # # apparently working method
  # def self.follow(user, other_user)
  #   return if user.following.include?(other_user)

  #   user.following << other_user
  # end

  def unfollow(other_user)
    return unless following.include?(other_user)

    following.delete(other_user)
    other_user.followers.delete(self)
  end

  # callbacks
  def downcase_email
    self.email_address = email_address.delete(' ').downcase
  end

  def generate_confirmation_instructions
    self.confirmation_token = SecureRandom.hex(10)
    self.confirmation_sent_at = Time.now.utc
  end
end
