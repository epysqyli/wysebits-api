class TileEntry < ApplicationRecord
  # model associations
  belongs_to :book_tile
  has_many :comments, as: :commentable, dependent: :destroy

  has_many :fav_tile_entries
  has_many :liking_users, through: :fav_tile_entries, source: :user

  has_and_belongs_to_many :upvoters, class_name: 'User', join_table: 'upvoted_entries_users',
                                     foreign_key: 'tile_entry_id'

  has_and_belongs_to_many :downvoters, class_name: 'User', join_table: 'downvoted_entries_users',
                                       foreign_key: 'tile_entry_id'
  # model methods
  def add_liking_user(user)
    return if liking_users.include?(user)

    liking_users << user
  end

  def update_net_votes
    self.net_votes = upvotes - downvotes
    save
  end

  def self.other_user_entries(logged_user)
    TileEntry.where.not(book_tile_id: BookTile.where(user_id: logged_user.id))
  end
end
