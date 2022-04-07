class WeekTrendJob < ApplicationJob
  include Redisable

  queue_as :default

  def perform
    process_trending_book
    process_trending_user
    process_trending_insight
  end

  private

  def process_trending_book
    books = Book.distinct.where(id: BookTile.pluck(:book_id))
    books.each do |book|
      book.tiles_count_diff = book.tiles_count - book.previous_tiles_count
      book.save
    end

    trending_book = BookFormat.authors_category(
      Book.includes(%i[authors category]).order(tiles_count_diff: :desc).first
    )

    cache('trending_book', trending_book)
  end

  def process_trending_user
    users = User.distinct.where(id: BookTile.pluck(:user_id))
    users.each do |user|
      user.tiles_count_diff = user.tiles_count - user.previous_tiles_count
      user.save
    end

    trending_user = UserFormat.username_tiles_diff_avatar(User.order(tiles_count_diff: :desc).first)
    cache('trending_user', trending_user)
  end

  def process_trending_insight
    TileEntry.all.each do |insight|
      insight.upvotes_diff = insight.upvotes - insight.previous_upvotes
      insight.save
    end

    trending_insight = TileEntryFormat.booktile_book_user(
      TileEntry.includes(book_tile: %i[user book]).order(upvotes_diff: :desc).first
    )

    cache('trending_insight', trending_insight)
  end
end
