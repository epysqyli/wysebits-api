class BookTile < ApplicationRecord
  belongs_to :user
  belongs_to :book
  has_many :tile_entries, dependent: :destroy
  has_many :temporary_entries, dependent: :destroy

  def update_book_tiles_count
    book = Book.find book_id
    book.tiles_count += 1
    book.save
  end

  after_commit :update_book_tiles_count
end
