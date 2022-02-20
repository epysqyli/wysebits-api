# Create book_tiles
books = Book.limit(100)
users = User.all

10.times do
  BookTile.create! book_id: books.sample.id, user_id: users.sample.id
end

# Create tile_entries
BookTile.all.each do |book_tile|
  3.times do
    TileEntry.create!(
      content: Faker::Lorem.sentence(word_count: 25),
      upvotes: rand(1..10),
      downvotes: rand(1..10),
      book_tile_id: book_tile.id
    )
  end
end

# Create comments to tile_entries
TileEntry.all.each do |entry|
  Comment.create!(
    content: Faker::Lorem.sentence(word_count: 15),
    user_id: User.all.sample.id,
    commentable_id: entry.id,
    commentable_type: entry.class.to_s
  )
end

# Create comments as replies to other comments
Comment.all.each do |comment|
  Comment.create(
    content: Faker::Lorem.sentence(word_count: 15),
    user_id: User.all.sample.id,
    commentable_id: comment.id,
    commentable_type: comment.class.to_s
  )
end
