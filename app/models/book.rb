class Book < ApplicationRecord
  # model associations
  belongs_to :category
  has_many :book_tiles
  has_and_belongs_to_many :authors, join_table: 'authors_books', foreign_key: 'book_id'
  has_and_belongs_to_many :subjects, join_table: 'subjects_books', foreign_key: 'book_id'

  has_many :fav_books
  has_many :liking_users, through: :fav_books, source: :user

  has_one :metric_data
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

  def find_or_create_metric_data
    unless metric_data
      new_metric_data = MetricData.new(
        fav_books_count: 0,
        fav_entries_count: 0,
        upvotes_count: 0,
        downvotes_count: 0
      )
      self.metric_data = new_metric_data
    end

    metric_data
  end

  def rank_score
    book_tiles.size + metric_data.fav_books_count * 0.5 + metric_data.fav_entries_count * 0.9 + metric_data.upvotes_count * 0.75 + metric_data.downvotes_count * 0.7
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

  def self.import
    includes(:category, :authors).find_in_batches do |books|
      bulk_index(books)
    end
  end

  def self.bulk_index(books)
    __elasticsearch__.client.bulk({
                                    index: __elasticsearch__.index_name,
                                    type: '_doc',
                                    body: map_for_import(books)
                                  })
  end

  def map_for_import(books)
    books.map { |book| { index: { _id: book.id, data: book.as_indexed_json } } }
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
    as_json(include: %i[authors category])
  end

  def self.search(query, from = 0)
    __elasticsearch__.search(
      {
        query: {
          multi_match:
          {
            query: query,
            fields: %w[title authors category],
            fuzziness: 'AUTO'
          }
        },
        size: 20,
        from: from,
        highlight: {
          pre_tags: ['<b>'],
          post_tags: ['</b>'],
          fields: { title: {} }
        }
      }
    )
  end
end
