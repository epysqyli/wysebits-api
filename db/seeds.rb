# User seeder
10.times do
  psw = Faker::Internet.password

  User.create!(
    name: Faker::Name.unique.first_name,
    surname: Faker::Name.unique.last_name,
    username: Faker::Internet.unique.username,
    email_address: Faker::Internet.unique.email,
    password: psw,
    password_confirmation: psw
  )
end

# Category seeder
categories = ['History', 'Philosophy', 'Religion and Spirituality', 'Science', 'Popular Science',
              'Politics and Social Sciences', 'Essay', 'Self-Help', 'Business and Economics', 'Health and Wellness', 'Crafts and Hobbies', 'Travel Guides
              ', 'Cookbooks', 'Parenting and Family', 'Children’s Nonfiction', 'Educational Guides', 'Textbooks', 'Language Books', 'Humor', 'Arts Books', 'Memoirs and autobiographies', 'Biographies', 'Travel Literature', 'Journalism', 'CATCHALL']

categories.each { |cat_name| Category.create! name: cat_name }

# Subject seeder
20.times { Subject.create! name: Faker::Lorem.unique.sentence(word_count: 1) }

# Book seeder
categories = Category.all
20.times do
  Book.create!(
    title: Faker::Book.unique.title,
    category_id: categories.sample.id
  )
end

# Assign subjects to books
subjects = Subject.all
books = Book.all

books.each do |book|
  book.add_subject subjects.sample
  book.add_subject subjects.sample
end

# Author seeder
20.times do
  Author.create!(
    name: Faker::Book.unique.author.split(' ').first,
    surname: Faker::Book.unique.author.split(' ').last
  )
end

# Assign authors to books
books = Book.all
authors = Author.all

books.each { |book| book.add_author(authors.sample) }

# Create book_tiles
books = Book.all
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
