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

  has_and_belongs_to_many :upvoted_entries,
                          class_name: 'TileEntry',
                          join_table: 'upvoted_entries_users',
                          foreign_key: 'user_id'

  has_and_belongs_to_many :downvoted_entries,
                          class_name: 'TileEntry',
                          join_table: 'downvoted_entries_users',
                          foreign_key: 'user_id'

  has_and_belongs_to_many :fav_categories,
                          class_name: 'Category',
                          join_table: 'categories_users',
                          foreign_key: 'user_id'

  # following and followers
  has_many :active_relationships, class_name: 'Relationship', foreign_key: 'follower_id', dependent: :destroy
  has_many :following, through: :active_relationships, source: :followed

  has_many :passive_relationships, class_name: 'Relationship', foreign_key: 'followed_id', dependent: :destroy
  has_many :followers, through: :passive_relationships

  has_many :conversations
  has_many :messages

  # validations
  validates :email_address, presence: true, uniqueness: true, length: { minimum: 8, maximum: 125 },
                            format: { with: /^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$/, multiline: true }

  validates :username, presence: true, length: { minimum: 4, maximum: 12 }
  validates :password, presence: true,
                       format: {
                         with: /^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$/,
                         multiline: true
                       }, on: :create

  def handle_attachment(user_image)
    avatar.attach(user_image)
  end

  def entries_stats
    top_entry = all_tile_entries.order(upvotes: :desc)
                                .includes({ book_tile: [{ book: %i[authors category] }, :user] }).first

    bottom_entry = all_tile_entries.order(upvotes: :asc)
                                   .includes({ book_tile: [{ book: %i[authors category] }, :user] }).first

    best_net_entry = all_tile_entries.order(net_votes: :desc)
                                     .includes({ book_tile: [{ book: %i[authors category] }, :user] }).first

    { most_upvoted: top_entry, most_downvoted: bottom_entry, best_net_entry: best_net_entry }
  end

  def follow(other_user)
    following << other_user unless following.include?(other_user)
  end

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

  def all_book_insights(book)
    TileEntry.where(book_tile: BookTile.where(user: self, book: book))
  end

  def conversations
    Conversation.where(sender_id: id).or(Conversation.where(recipient_id: id))
  end

  def send_message(conversation, content)
    Message.create! user: self, content: content, conversation: conversation
  end

  # methods related to username and password confirmation and update
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

  def self.username_available?(new_username)
    return true if User.find_by_username(new_username).nil?

    false
  end

  def self.email_address_available?(new_email_address)
    return true if User.find_by_email_address(new_email_address).nil?

    false
  end

  def start_email_update!(email)
    self.unconfirmed_email = email
    generate_confirmation_instructions
    save
  end

  def self.email_used?(email)
    existing_user = find_by_email_address email
    return true if existing_user.present?

    unconfirmed_email_user = find_by_unconfirmed_email email
    unconfirmed_email_user.present? && waiting_for_confirmation.confirmation_token_valid?
  end

  def update_new_email!
    self.email_address = unconfirmed_email
    self.unconfirmed_email = nil
    mark_as_confirmed!
  end

  def tiles_number
    TileEntry.where(book_tile: BookTile.where(user: self)).count / BookTile::NUMBER_OF_TILE_ENTRIES
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
