class Book < ApplicationRecord
  belongs_to :category
  has_many :book_tiles
  has_and_belongs_to_many :authors, join_table: 'authors_books', foreign_key: 'author_id'
  has_and_belongs_to_many :subjects, join_table: 'subjects_books', foreign_key: 'subject_id'

  def add_subject(subject)
    return if subjects.include?(subject)

    subjects << subject
    subject.books << self
  end

  def add_author(author)
    return if authors.include?(author)

    authors << author
    author.books << self
  end

  def self.search(keywords)
    Book.where((['title ILIKE ?'] * keywords.size).join(' OR '), * keywords.map { |k| "%#{k}%" })
  end
end
