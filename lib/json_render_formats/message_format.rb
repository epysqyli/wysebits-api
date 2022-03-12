class MessageFormat
  def self.json_user(input)
    input.as_json(include: { user: { only: %i[username id] } })
  end
end
