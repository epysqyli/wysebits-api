class Author < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search,
                  against: :full_name,
                  using: { tsearch: { dictionary: 'english', tsvector_column: 'searchable' } }

  has_and_belongs_to_many :books, join_table: 'authors_books', foreign_key: 'author_id'

  # validates_uniqueness_of :full_name, on: :create
end
