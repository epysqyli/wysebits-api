class Author < ApplicationRecord
  # elasticsearch concern
  include AuthorSearchable

  include PgSearch::Model
  pg_search_scope :search_author,
                  against: :full_name,
                  using: { tsearch: {dictionary: 'english', tsvector_column: 'searchable' } }

  has_and_belongs_to_many :books, join_table: 'authors_books', foreign_key: 'author_id'
end
