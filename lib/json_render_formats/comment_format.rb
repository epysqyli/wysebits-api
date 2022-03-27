class CommentFormat
  def self.username_only(input)
    input.as_json(include: { user: { only: :username } })
  end
end
