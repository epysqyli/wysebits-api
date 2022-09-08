namespace :db do
  desc 'Create default categories'
  task create_categories: :environment do
    Category::CATEGORIES.each { |cat| Category.create! name: cat, slug: cat.downcase.gsub(/ /, '-') }
  end

  desc 'Import books in bulk from openlibrary csv - not working after tsvector migration'
  task :import_books_bulk, [:ol_dump] => :environment do |_t, args|
    various_category = Category.find_by_slug 'various'
    headers = %w[type key revision last_modified json]
    SmarterCSV.process(args[:ol_dump], chunk_size: 30_000, col_sep: "\t", user_provided_headers: headers,
                                       quote_char: "\x00", invalid_byte_sequence: '') do |chunk|
      books = Parallel.map(chunk) do |row|
        next if row.nil?

        work = JSON.parse(row[:json])
        book = Book.new
        book.title = work['title']
        book.title = book.title.tr("\u0000", '') unless book.title.nil?
        book.category = various_category

        unless work['authors'].nil? || work['authors'][0]['author'].nil? || work['authors'][0]['author']['key'].nil?
          book.ol_author_key = work['authors'][0]['author']['key']&.split('/')&.last
          book.ol_author_key = book.ol_author_key.tr("\u0000", '') unless book.ol_author_key.nil?
        end

        book.ol_key = work['key']&.split('/')&.last unless work['key'].nil?
        book.ol_key = book.ol_key.tr("\u0000", '') unless book.ol_key.nil?
        next if book.nil?

        book
      end

      Book.import books, batch_size: 10_000
      puts 'Batch imported'
    end
  end

  desc 'Import authors in bulk from openlibrary csv - not working after tsvector migration'
  task :import_authors_bulk, [:ol_dump] => :environment do |_t, args|
    headers = %w[type key revision last_modified json]
    SmarterCSV.process(args[:ol_dump], chunk_size: 30_000, col_sep: "\t", headers: false,
                                       user_provided_headers: headers, quote_char: "\x00") do |chunk|
      people = Parallel.map(chunk) do |row|
        next if row.nil?

        person = JSON.parse(row[:json])
        author = Author.new
        author.full_name = person['name']
        author.key = person['key']&.split('/')&.last unless person['key'].nil?

        next if author.nil?

        author
      end

      Author.import people, batch_size: 7_500
    end
  end

  desc 'Import books from openlibrary csv'
  task :import_books, [:ol_dump] => :environment do |_t, args|
    col_sep = args[:ol_dump].include?('recent') ? ',' : "\t"
    various_category = Category.find_by_slug 'various'
    CSV.foreach(args[:ol_dump], col_sep: col_sep, headers: true, liberal_parsing: true) do |row|
      next if row.nil?

      work = JSON.parse(row['json'])
      book = Book.new
      book.title = work['title']
      book.category = various_category

      unless work['authors'].nil? || work['authors'][0]['author'].nil? || work['authors'][0]['author']['key'].nil?
        book.ol_author_key = work['authors'][0]['author']['key']&.split('/')&.last
      end

      book.ol_key = work['key']&.split('/')&.last unless work['key'].nil?
      next if book.nil?

      book.save
    end
  end

  desc 'Import authors from openlibrary csv'
  task :import_authors, [:ol_dump] => :environment do |_t, args|
    col_sep = args[:ol_dump].include?('recent') ? ',' : "\t"
    CSV.foreach(args[:ol_dump], col_sep: col_sep, headers: true, liberal_parsing: true) do |row|
      next if row.nil?

      person = JSON.parse(row['json'])
      author = Author.new
      author.full_name = person['name']
      author.key = person['key']&.split('/')&.last unless person['key'].nil?

      next if author.nil?

      author.save
    end
  end

  desc 'Assign authors to books'
  task assign_authors: :environment do
    command = 'INSERT INTO authors_books (author_id, book_id) SELECT authors.id, books.id FROM books INNER JOIN '\
    'authors ON books.ol_author_key = authors.key;'
    ActiveRecord::Base.connection.execute(command)
  end
end
