class User < ApplicationRecord
  before_save :downcase_email
  before_create :generate_confirmation_instructions

  has_secure_password

  # model associations
  has_many :book_tiles

  has_many :comments
  has_and_belongs_to_many :fav_books, class_name: 'Book', join_table: 'books_users', foreign_key: 'user_id'
  has_and_belongs_to_many :fav_tile_entries, class_name: 'TileEntry', join_table: 'tile_entries_users',
                                             foreign_key: 'user_id'

  has_and_belongs_to_many :upvoted_entries, class_name: 'TileEntry', join_table: 'upvoted_entries_users',
                                            foreign_key: 'user_id'

  has_and_belongs_to_many :downvoted_entries, class_name: 'TileEntry', join_table: 'downvoted_entries_users',
                                              foreign_key: 'user_id'

  has_many :active_relationships, class_name: 'Relationship', foreign_key: 'follower_id', dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed

  has_many :passive_relationships, class_name: 'Relationship', foreign_key: 'followed_id', dependent: :destroy
  has_many :followers, through: :passive_relationships

  # validations
  validates :email_address, presence: true, uniqueness: true, length: { minimum: 4, maximum: 125 },
                            format: { with: /^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$/, multiline: true, message: 'Invalid format' }

  validates :username, presence: true
  validates :password, presence: true
  validates :password_confirmation, presence: true

  # model methods
  def follow(other_user)
    following << other_user unless following.include?(other_user)
  end

  def unfollow(other_user)
    return unless following.include?(other_user)

    following.delete(other_user)
    other_user.followers.delete(self)
  end

  def add_to_fav_books(book)
    fav_books << book unless fav_books.include?(book)
  end

  def remove_from_fav_books(book)
    fav_books.delete(book) if fav_books.include?(book)
  end

  def add_to_fav_tile_entries(entry)
    fav_tile_entries << entry unless fav_tile_entries.include?(entry)
  end

  def remove_from_fav_tile_entries(entry)
    fav_tile_entries.delete(entry) if fav_tile_entries.include?(entry)
  end

  def upvote(entry)
    return if upvoted_entries.include?(entry)

    remove_downvote(entry) if downvoted_entries.include?(entry)

    entry.upvotes += 1
    upvoted_entries << entry
  end

  def remove_upvote(entry)
    return unless upvoted_entries.include?(entry)

    entry.upvotes -= 1
    upvoted_entries.delete(entry)
    entry.save
  end

  def downvote(entry)
    return if downvoted_entries.include?(entry)

    remove_upvote(entry) if upvoted_entries.include?(entry)

    entry.downvotes += 1
    downvoted_entries << entry
  end

  def remove_downvote(entry)
    return unless downvoted_entries.include?(entry)

    entry.downvotes -= 1
    downvoted_entries.delete(entry)
    entry.save
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
