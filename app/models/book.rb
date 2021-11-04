class Book < ApplicationRecord
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

  # elasticsearch configuration
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  settings index: { number_of_shards: 2 } do
    mapping dynamic: false do
      indexes :title, analyzer: :english
      indexes :category, type: 'nested' do
        indexes :name, analyzer: :english
      end
      indexes :authors, type: 'nested' do
        indexes :full_name, analyzer: :standard
      end
    end
  end

  def as_indexed_json(_options = {})
    as_json(
      include: %i[authors category]
    )
  end

  # Implement pagination
  def self.search(query)
    __elasticsearch__.search(
      {
        query: {
          multi_match: { query: query, fields: %w[title authors category], fuzziness: 'AUTO' }
        },
        size: 50,
        highlight: {
          pre_tags: ['<b>'],
          post_tags: ['</b>'],
          fields: { title: {} }
        }
      }
    )
  end
end
