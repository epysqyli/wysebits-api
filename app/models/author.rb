class Author < ApplicationRecord
  # elasticsearch concern
  include AuthorSearchable

  has_and_belongs_to_many :books, join_table: 'authors_books', foreign_key: 'author_id'
end
