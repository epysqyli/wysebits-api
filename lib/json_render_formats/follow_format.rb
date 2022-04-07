class FollowFormat
  def self.follow_booktile_entries_follower(input)
    input.as_json(include:
      { follower: { only: %i[username id avatar_url], include: { book_tiles: { include: :tile_entries } } } })
  end

  def self.follow_booktile_entries_followed(input)
    input.as_json(include:
      { followed: { only: %i[username id avatar_url], include: { book_tiles: { include: :tile_entries } } } })
  end
end
