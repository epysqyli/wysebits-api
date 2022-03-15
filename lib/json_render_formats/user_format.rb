class UserFormat
  def self.username_tiles_diff_avatar(input)
    input.as_json(only: %i[username tiles_count_diff avatar_url])
  end
end
