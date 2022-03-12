class AuthorFormat
  def self.json_authors_category(input)
    input.as_json(include: %i[authors category])
  end
end
