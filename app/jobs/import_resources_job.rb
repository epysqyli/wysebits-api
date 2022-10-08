class ImportResourcesJob < ApplicationJob
  queue_as :default

  def perform
    import_authors
    import_works
  end

  private

  def import_works
    various_category = Category.find_by_slug 'various'

    SmarterCSV.process('/home/elvis/tasks/openlibrary-diff-go/recent_works.txt',
                       headers_in_file: false,
                       user_provided_headers: ['json_entry'],
                       col_sep: "\t",
                       chunk_size: 30_000,
                       quote_char: "\x00",
                       invalid_byte_sequence: '') do |chunk|
      books = Parallel.map(chunk) do |row|
        next if row.nil?

        work = JSON.parse(row[:json_entry])
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
    end

    Book.where(created_at: 1.month.ago..).import
  end

  def import_authors
    SmarterCSV.process('/home/elvis/tasks/openlibrary-diff-go/recent_works.txt',
                       headers_in_file: false,
                       user_provided_headers: ['json_entry'],
                       col_sep: "\t",
                       chunk_size: 30_000,
                       quote_char: "\x00") do |chunk|
      people = Parallel.map(chunk) do |row|
        next if row.nil?

        person = JSON.parse(row[:json_entry])
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
