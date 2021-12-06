class Book < ApplicationRecord
  # model associations
  belongs_to :category
  has_many :book_tiles
  has_and_belongs_to_many :authors, join_table: 'authors_books', foreign_key: 'book_id'
  has_and_belongs_to_many :subjects, join_table: 'subjects_books', foreign_key: 'book_id'
  has_and_belongs_to_many :liking_users, class_name: 'User', join_table: 'books_users', foreign_key: 'book_id'
  has_one_attached :book_cover

  # model validations
  validates :title, presence: true, uniqueness: true

  # model methods
  def add_subject(subject)
    return if subjects.include?(subject)

    subjects << subject
  end

  def add_author(author)
    return if authors.include?(author)

    authors << author

    __elasticsearch__.index_document
  end

  def replace_author(author)
    authors.each { |aut| authors.delete(aut) } unless authors.empty?
    add_author(author)
  end

  def add_liking_users(user)
    return if liking_users.include?(user)

    liking_users << user
  end

  def handle_attachment(cover)
    book_cover.attach(cover)
  end

  def all_tile_entries
    TileEntry.where(book_tile_id: BookTile.where(book_id: id))
  end

  # elasticsearch configuration
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  after_commit on: [:create] do
    __elasticsearch__.index_document
  end

  after_commit on: [:update] do
    __elasticsearch__.update_document
  end

  after_commit on: [:destroy] do
    __elasticsearch__.delete_document
  end

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
