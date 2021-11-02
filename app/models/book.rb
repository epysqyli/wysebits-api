class Book < ApplicationRecord
  belongs_to :category
  has_many :book_tiles
  has_and_belongs_to_many :authors, join_table: 'authors_books', foreign_key: 'book_id'
  has_and_belongs_to_many :subjects, join_table: 'subjects_books', foreign_key: 'book_id'

  validates :title, presence: true, uniqueness: true

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

  # need for pagination
  def self.search(keywords)
    Book.where((['title ILIKE ?'] * keywords.size).join(' AND '), * keywords.map { |k| "%#{k}%" }).eager_load(:category, :authors).limit(100)
  end
end
