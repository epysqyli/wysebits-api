class WeekTrendJob < ApplicationJob
  queue_as :default

  def perform
    process_trending_book
    process_trending_user
    process_trending_insight
  end

  private

  def redis
    Redis.new
  end

  def cache(key, value)
    redis.set(key, JSON.dump(value))
  end

  def process_trending_book
    books = BookTile.includes(:book).map(&:book)
    books.each do |book|
      book.tiles_count_diff = book.tiles_count - book.previous_tiles_count
      book.save
    end

    trending_book = BookFormat.json_authors_category(
      Book.includes(%i[authors category]).order(tiles_count_diff: :desc).first
    )

    cache('trending_book', trending_book)
  end

  def process_trending_user
    users = BookTile.includes(:user).map(&:user)
    users.each do |user|
      user.tiles_count_diff = user.tiles_count - user.previous_tiles_count
      user.save
    end

    trending_user = User.order(tiles_count_diff: :desc).first.as_json(only: %i[username tiles_count_diff avatar_url])
    cache('trending_user', trending_user)
  end

  def process_trending_insight
    TileEntry.all.each do |insight|
      insight.upvotes_diff = insight.upvotes - insight.previous_upvotes
      insight.save
    end

    trending_insight = TileEntryFormat.json_booktile_book_user(
      TileEntry.includes(book_tile: %i[user book]).order(upvotes_diff: :desc).first
    )

    cache('trending_insight', trending_insight)
  end
end
