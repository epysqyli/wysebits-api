class BookTileFormat
  def self.json_entries_book_authors_category(input)
    input.as_json(include: [:tile_entries, { book: { include: %i[authors category] } }])
  end

  def self.json_entries(input)
    input.as_json(include: :tile_entries)
  end

  def self.json_entries_book_authors_category_temp(input)
    input.as_json(include: [:tile_entries, { book: { include: %i[authors category] } }, :temporary_entries])
  end
end
