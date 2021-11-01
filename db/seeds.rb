# # User seeder
# 10.times do
#   psw = Faker::Internet.password

#   User.create!(
#     name: Faker::Name.unique.first_name,
#     surname: Faker::Name.unique.last_name,
#     username: Faker::Internet.unique.username,
#     email_address: Faker::Internet.unique.email,
#     password: psw,
#     password_confirmation: psw
#   )
# end

# # Category seeder
# categories = ['History', 'Philosophy', 'Religion and Spirituality', 'Science', 'Popular Science',
#               'Politics and Social Sciences', 'Essay', 'Self-Help', 'Business and Economics', 'Health and Wellness', 'Crafts and Hobbies', 'Travel Guides
#               ', 'Cookbooks', 'Parenting and Family', 'Children’s Nonfiction', 'Educational Guides', 'Textbooks', 'Language Books', 'Humor', 'Arts Books', 'Memoirs and autobiographies', 'Biographies', 'Travel Literature', 'Journalism', 'CATCHALL']

# categories.each { |cat_name| Category.create! name: cat_name }

# # Book seeder
# last_category_id = Category.last.id
# works = Rails.root.join('lib', 'seeds', 'works.csv')

# SmarterCSV.process(works, chunk_size: 20_000) do |chunk|
#   books = Parallel.map(chunk) do |row|
#     next if row.nil?

#     work = JSON.parse(row[:json])

#     book = Book.new

#     book.title = work['title']
#     book.category_id = last_category_id

#     unless work['authors'].nil? || work['authors'][0]['author'].nil? || work['authors'][0]['author']['key'].nil?
#       book.ol_author_key = work['authors'][0]['author']['key']&.split('/')&.last
#     end

#     book.ol_key = work['key']&.split('/')&.last unless work['key'].nil?

#     next if book.nil?

#     book
#   end

#   Book.import books, batch_size: 5_000
# end

# # Author seeder
# seed db from authors csv file

# # Assign authors to books
# based on ol data

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
