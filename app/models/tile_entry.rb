class TileEntry < ApplicationRecord
  # model associations
  belongs_to :book_tile
  has_many :comments, as: :commentable, dependent: :destroy
  has_and_belongs_to_many :liking_users, class_name: 'User', join_table: 'tile_entries_users',
                                         foreign_key: 'tile_entry_id'

  has_and_belongs_to_many :downvoters, class_name: 'User', join_table: 'downvoted_entries_users',
                                         foreign_key: 'tile_entry_id'
  # model methods
  def add_liking_user(user)
    return if liking_users.include?(user)

    liking_users << user
  end
end
