# # User seeder
# 10.times do
#   User.create!(
#     name: Faker::Name.unique.first_name,
#     surname: Faker::Name.unique.last_name,
#     email_address: Faker::Internet.unique.email,
#     password: Faker::Internet.password
#   )
# end

# # Category seeder
# 10.times { Category.create! name: Faker::Book.unique.genre }

## Subject seeder
# 20.times { Subject.create! name: Faker::Lorem.unique.sentence(word_count: 1) }

# # Book seeder
# categories = Category.all
# 10.times do
#   Book.create!(
#     title: Faker::Book.unique.title,
#     category_id: categories[rand(1..12)].id
#   )
# end

# # Assign subjects to books
# subjects = Subject.all
# books = Book.all

# books.each do |book|
#   book.add_subject subjects[rand(1..20)]
#   book.add_subject subjects[rand(1..20)]
# end

# # Author seeder
# 20.times do
#   Author.create!(
#     name: Faker::Book.unique.author.split(' ').first,
#     surname: Faker::Book.unique.author.split(' ').last
#   )
# end

# # Assign authors to books
# books = Book.all
# authors = Author.all

# books.each { |book| book.add_author(authors[rand(1..20)]) }

# # Create book_tiles
# books = Book.all
# users = User.all

# 10.times do
#   BookTile.create! book_id: books.sample.id, user_id: users.sample.id
# end

# # Create tile_entries
# BookTile.all.each do |book_tile|
#   3.times do
#     TileEntry.create!(
#       content: Faker::Lorem.sentence(word_count: 25),
#       upvotes: rand(1..10),
#       downvotes: rand(1..10),
#       book_tile_id: book_tile.id
#     )
#   end
# end

# # Create comments to tile_entries
# TileEntry.all.each do |entry|
#   Comment.create!(
#     content: Faker::Lorem.sentence(word_count: 15),
#     user_id: User.all.sample.id,
#     commentable_id: entry.id,
#     commentable_type: entry.class.to_s
#   )
# end

# # Create comments as replies to other comments
# Comment.all.each do |comment|
#   Comment.create(
#     content: Faker::Lorem.sentence(word_count: 15),
#     user_id: User.all.sample.id,
#     commentable_id: comment.id,
#     commentable_type: comment.class.to_s
#   )
# end
