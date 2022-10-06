class ImportResourcesJob < ApplicationJob
  queue_as :default

  def perform
    import_works
    import_authors
  end

  private

  def import_works
    various_category = Category.find_by_slug 'various'
    headers = %w[type key revision last_modified json]

    SmarterCSV.process(ENV['recent_works'],
                       chunk_size: 30_000,
                       col_sep: ',',
                       user_provided_headers: headers,
                       quote_char: "\x00",
                       invalid_byte_sequence: '') do |chunk|
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

      Book.bulk_import books, batch_size: 10_000
      puts 'Batch imported into postgre DB'
    end

    Book.where(created_at: 1.month.ago..).import
  end

  def import_authors
    headers = %w[type key revision last_modified json]
    SmarterCSV.process(ENV['recent_authors'],
                       chunk_size: 30_000,
                       col_sep: ',',
                       headers: false,
                       user_provided_headers: headers,
                       quote_char: "\x00") do |chunk|
      people = Parallel.map(chunk) do |row|
        next if row.nil?

        person = JSON.parse(row[:json])
        author = Author.new
        author.full_name = person['name']
        author.key = person['key']&.split('/')&.last unless person['key'].nil?

        next if author.nil?

        author
      end

      Author.bulk_import people, batch_size: 7_500
    end
  end
end
