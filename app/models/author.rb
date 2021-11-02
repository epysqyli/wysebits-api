class Author < ApplicationRecord
  has_and_belongs_to_many :books, join_table: 'authors_books', foreign_key: 'author_id'
end
