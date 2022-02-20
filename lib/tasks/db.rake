namespace :db do
  desc 'Create default categories'
  task create_categories: :environment do
    categories = ['History', 'Philosophy', 'Religion and Spirituality', 'Science', 'Politics',
                  'Social Sciences', 'Essay', 'Self-Help', 'Business',
                  'Economics and Finance', 'Health and Wellness', 'Crafts and Hobbies', 'Academic Texts',
                  'Language Books', 'Arts Books', 'Memoirs and autobiographies', 'Biographies',
                  'Journalism', 'Guides and How To Manuals', 'Various']

    categories.each { |cat| Category.create! name: cat, slug: name.downcase.gsub(/ /, '-') }
  end

  desc 'Import books from openlibrary csv'
  task import_books: :environment do
    works = Rails.root.join('lib', 'seeds', 'works.csv')
    various_category = Category.find 25
    SmarterCSV.process(works, chunk_size: 20_000) do |chunk|
      books = Parallel.map(chunk) do |row|
        next if row.nil?

        work = JSON.parse(row[:json])
        book = Book.new
        book.title = work['title']
        book.category_id = various_category

        unless work['authors'].nil? || work['authors'][0]['author'].nil? || work['authors'][0]['author']['key'].nil?
          book.ol_author_key = work['authors'][0]['author']['key']&.split('/')&.last
        end

        book.ol_key = work['key']&.split('/')&.last unless work['key'].nil?
        next if book.nil?

        book
      end

      Book.import books, batch_size: 5_000
    end
  end

  desc 'Import authors from openlibrary csv'
  task import_authors: :environment do
    authors = Rails.root.join('lib', 'seeds', 'authors.csv')
    SmarterCSV.process(authors, chunk_size: 30_000) do |chunk|
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

  desc 'Assign authors to books'
  task assign_authors: :environment do
    progress = 0
    Book.all.in_batches(of: 30_000) do |batch|
      Parallel.each(batch) do |book|
        next if book.ol_author_key.nil?

        author_key = book.ol_author_key
        author = Author.find_by_key(author_key)
        book.add_or_replace_author(author)
      end

      progress += batch.length
      puts "#{progress} books processed\n"
    end
  end
end
