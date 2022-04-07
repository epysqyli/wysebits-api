class AuthorFormat
  def self.authors_category(input)
    input.as_json(include: %i[authors category])
  end
end
