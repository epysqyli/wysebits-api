class TileEntryFormat
  def self.json_booktile_book_authors_category_user(input)
    input.as_json(include: { book_tile: { include: [{ book: { include: %i[authors category] } },
                                                    { user: { only: %i[username id] } }] } })
  end

  def self.json_booktile_book_user(input)
    input.as_json(include: { book_tile: { include: [:book, { user: { only: %i[id username] } }] } })
  end
end
