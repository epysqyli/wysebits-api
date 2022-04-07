class BookTileFormat
  def self.entries_book_authors_category(input)
    input.as_json(include: [:tile_entries, { book: { include: %i[authors category] } }])
  end

  def self.entries(input)
    input.as_json(include: :tile_entries)
  end

  def self.entries_book_authors_category_temp(input)
    input.as_json(include: [:tile_entries, { book: { include: %i[authors category] } }, :temporary_entries])
  end

  def self.entries_tiles_books_user_books(input)
    input.as_json(include: [{ tile_entries:
      { include: { book_tile: { include: [:book, { user: { only: %i[id username] } }] } } } },
                            { book: { include: %i[authors category] } }])
  end
end
