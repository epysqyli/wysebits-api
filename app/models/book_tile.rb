class BookTile < ApplicationRecord
  belongs_to :user
  belongs_to :book
  has_many :tile_entries, dependent: :destroy
  has_many :temporary_entries, dependent: :destroy

  after_commit :update_book_tiles_count

  def update_book_tiles_count
    book = Book.find book_id
    book.tiles_count = book.book_tiles.size
    book.save
  end
end
