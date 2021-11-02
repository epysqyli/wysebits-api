class Author < ApplicationRecord
  has_and_belongs_to_many :books, join_table: 'authors_books', foreign_key: 'book_id'

  # remove if seeding db preemtively works
  def books
    Book.where(ol_author_key: key)
  end
end
