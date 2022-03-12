class BookFormat
  def self.json_tiles_user(input)
    input.as_json(include: [book_tile: { include: [user: { only: %i[username id] }] }])
  end

  def self.json_authors_category(input)
    input.as_json(include: %i[authors category])
  end

  def self.json_book_authors_category(input)
    input.as_json(include: { book: { include: %i[authors category] } })
  end
end
