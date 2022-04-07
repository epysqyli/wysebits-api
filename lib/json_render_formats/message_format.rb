class MessageFormat
  def self.user(input)
    input.as_json(include: { user: { only: %i[username id] } })
  end
end
