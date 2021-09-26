class Book < ApplicationRecord
  belongs_to :category
  has_and_belongs_to_many :authors, join_table: 'authors_books', foreign_key: 'author_id'
  has_and_belongs_to_many :subjects, join_table: 'subjects_books', foreign_key: 'subject_id'
end
