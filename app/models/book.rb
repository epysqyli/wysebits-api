class Book < ApplicationRecord
  include PgSearch::Model
  pg_search_scope :search,
                  against: :title,
                  using: { tsearch:
                    { dictionary: 'english',
                      tsvector_column: 'searchable',
                      normalization: 2,
                      highlight: {
                        StartSel: '<u>',
                        StopSel: '</u>',
                        HighlightAll: true,
                        MinWords: 1,
                        MaxWords: 5
                      } } }

  # model associations
  belongs_to :category
  has_many :book_tiles
  has_and_belongs_to_many :authors, join_table: 'authors_books', foreign_key: 'book_id'
  has_and_belongs_to_many :subjects, join_table: 'subjects_books', foreign_key: 'book_id'

  has_many :fav_books
  has_many :liking_users, through: :fav_books, source: :user

  has_one :metric_data, dependent: :destroy
  has_one_attached :book_cover

  # model validations
  validates :title, presence: true

  # model methods
  def add_subject(subject)
    return if subjects.include?(subject)

    subjects << subject
  end

  def add_or_replace_author(author)
    return if authors.include?(author)

    authors << author
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

  def score
    find_or_create_metric_data unless metric_data
    metric_data.score
  end
end
