class User < ApplicationRecord
  before_save :downcase_email
  before_create :generate_confirmation_instructions

  has_secure_password

  has_one_attached :avatar

  # model associations
  has_many :book_tiles
  has_many :comments

  has_many :fav_books
  has_many :liked_books, through: :fav_books, source: :book

  has_many :fav_tile_entries
  has_many :liked_entries, through: :fav_tile_entries, source: :tile_entry

  has_and_belongs_to_many :upvoted_entries, class_name: 'TileEntry', join_table: 'upvoted_entries_users',
                                            foreign_key: 'user_id'

  has_and_belongs_to_many :downvoted_entries, class_name: 'TileEntry', join_table: 'downvoted_entries_users',
                                              foreign_key: 'user_id'

  has_and_belongs_to_many :fav_categories, class_name: 'Category', join_table: 'categories_users',
                                           foreign_key: 'user_id'

  has_many :active_relationships, class_name: 'Relationship', foreign_key: 'follower_id', dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed

  has_many :passive_relationships, class_name: 'Relationship', foreign_key: 'followed_id', dependent: :destroy
  has_many :followers, through: :passive_relationships

  # validations
  validates :email_address, presence: true, uniqueness: true, length: { minimum: 4, maximum: 125 },
                            format: { with: /^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$/, multiline: true, message: 'Invalid format' }

  validates :username, presence: true
  validates :password, presence: true, on: :create
  validates :password_confirmation, presence: true, on: :create

  def handle_attachment(user_image)
    avatar.attach(user_image)
  end

  def follow(other_user)
    following << other_user unless following.include?(other_user)
  end

  def self.username_available?(new_username)
    return true if User.find_by_username(new_username).nil?

    false
  end

  # model app logic methods

  def unfollow(other_user)
    return unless following.include?(other_user)

    following.delete(other_user)
    other_user.followers.delete(self)
  end

  def add_to_fav_books(book)
    liked_books << book unless liked_books.include?(book)
  end

  def remove_from_fav_books(book)
    liked_books.delete(book) if liked_books.include?(book)
  end

  def add_to_fav_tile_entries(entry)
    liked_entries << entry unless liked_entries.include?(entry)
  end

  def remove_from_fav_tile_entries(entry)
    liked_entries.delete(entry) if liked_entries.include?(entry)
  end

  def upvote(entry)
    return if upvoted_entries.include?(entry)

    remove_downvote(entry) if downvoted_entries.include?(entry)

    entry.upvotes += 1
    upvoted_entries << entry

    entry.update_net_votes
  end

  def remove_upvote(entry)
    return unless upvoted_entries.include?(entry)

    entry.upvotes -= 1
    upvoted_entries.delete(entry)
    entry.update_net_votes
  end

  def downvote(entry)
    return if downvoted_entries.include?(entry)

    remove_upvote(entry) if upvoted_entries.include?(entry)

    entry.downvotes += 1
    downvoted_entries << entry

    entry.update_net_votes
  end

  def remove_downvote(entry)
    return unless downvoted_entries.include?(entry)

    entry.downvotes -= 1
    downvoted_entries.delete(entry)
    entry.update_net_votes
  end

  def add_to_fav_categories(category)
    fav_categories << category if fav_categories.size < 3 && !fav_categories.include?(category)
  end

  def remove_from_fav_categories(category)
    fav_categories.delete(category) if fav_categories.include?(category)
  end

  def all_tile_entries
    TileEntry.where(book_tile_id: BookTile.where(user_id: id))
  end

  # user account confirmation and password reset methods
  def confirmation_token_valid?
    confirmation_sent_at + 30.days > Time.now.utc
  end

  def mark_as_confirmed!
    self.confirmation_token = nil
    self.confirmed_at = Time.now.utc
    save
  end

  def generate_password_token!
    self.reset_password_token = generate_token
    self.reset_password_sent_at = Time.now.utc
    save!
  end

  def password_token_valid?
    (reset_password_sent_at + 4.hours) > Time.now.utc
  end

  def reset_password!(password)
    self.reset_password_token = nil
    update(password: password)
  end

  private

  def generate_token
    SecureRandom.hex(10)
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
