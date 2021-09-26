class Subject < ApplicationRecord
  has_and_belongs_to_many :books, join_table: 'subjects_books', foreign_key: 'book_id'
end

# add model callback to implement automatic double binding association on many-to-many 