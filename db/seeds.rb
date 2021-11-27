# use bulk_import instead of import to avoid conflicts with es

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
# categories = ['History', 'Philosophy', 'Religion and Spirituality', 'Science','Politics', 'Social Sciences', 'Essay', 'Self-Help', 'Business', 'Economics', 'Health and Wellness', 'Crafts and Hobbies','Academic Texts', 'Language Books', 'Arts Books', 'Memoirs and autobiographies', 'Biographies','Journalism', 'Guides and How To Manuals' 'CATCHALL']

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
# authors = Rails.root.join('lib', 'seeds', 'authors.csv')

# SmarterCSV.process(authors, chunk_size: 30_000) do |chunk|
#   people = Parallel.map(chunk) do |row|
#     next if row.nil?

#     person = JSON.parse(row[:json])

#     author = Author.new

#     author.full_name = person['name']
#     author.key = person['key']&.split('/')&.last unless person['key'].nil?

#     next if author.nil?

#     author
#   end

#   Author.import people, batch_size: 7_500
# end

# # Assign authors to books
# progress = 0
# Book.all.in_batches(of: 30_000) do |batch|
#   Parallel.each(batch) do |book|
#     next if book.ol_author_key.nil?

#     author_key = book.ol_author_key
#     author = Author.find_by_key(author_key)

#     book.add_author(author)
#   end

#   progress += batch.length
#   puts "#{progress} books processed\n"
# end

# # Create book_tiles
# books = Book.limit(100)
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
