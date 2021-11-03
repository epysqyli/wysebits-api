class Book < ApplicationRecord
  # elasticsearch configuration
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  settings index: { number_of_shards: 2 } do
    mapping dynamic: false do
      indexes :title, analyzer: :english
    end
  end

  # model associations
  belongs_to :category
  has_many :book_tiles
  has_and_belongs_to_many :authors, join_table: 'authors_books', foreign_key: 'book_id'
  has_and_belongs_to_many :subjects, join_table: 'subjects_books', foreign_key: 'book_id'

  # model validations
  validates :title, presence: true, uniqueness: true

  # model methods
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

  # def self.search(keywords)
  #   Book.where((['title ILIKE ?'] * keywords.size).join(' AND '), * keywords.map { |k| "%#{k}%" }).eager_load(:category, :authors).limit(100)
  # end

  # Implement pagination
  def self.search(query)
    query = query.join(' ')
    __elasticsearch__.search(
      {
        query: {
          multi_match: { query: query, fields: ['title'] }
        },
        size: 20
      }
    )
  end
end
