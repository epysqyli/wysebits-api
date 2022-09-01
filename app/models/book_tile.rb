class BookTile < ApplicationRecord
  after_commit :update_tiles_count_on_book
  after_commit :update_tiles_count_on_user
  after_destroy :update_tiles_count_on_book
  after_destroy :update_tiles_count_on_user

  belongs_to :user
  belongs_to :book
  has_many :tile_entries, dependent: :destroy
  has_many :temporary_entries, dependent: :destroy

  NUMBER_OF_TILE_ENTRIES = 3

  private

  def update_tiles_count_on_book
    book.tiles_count = book.tiles_number
    book.save
  end

  def update_tiles_count_on_user
    user.tiles_count = BookTile.where(user: user).count
    user.save
  end
end
