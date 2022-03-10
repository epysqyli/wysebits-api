class BookTile < ApplicationRecord
  after_commit %i[update_tiles_count_on_book update_tiles_count_on_user]

  belongs_to :user
  belongs_to :book
  has_many :tile_entries, dependent: :destroy
  has_many :temporary_entries, dependent: :destroy

  private

  def update_tiles_count_on_book
    book.tiles_count += 1
  end

  def update_tiles_count_on_user
    user.tiles_count += 1
  end
end
