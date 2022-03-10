class WeekTrendJob < ApplicationJob
  queue_as :default

  def perform
    process_trending_book
    process_trending_user
    process_trending_insight
  end

  private

  def process_trending_book
    books = BookTile.includes(:book).map(&:book)
    books.each do |book|
      book.tiles_count_diff = book.tiles_count - book.previous_tiles_count
      book.save
    end
  end

  def process_trending_user
    users = BookTile.includes(:user).map(&:user)
    users.each do |user|
      user.tiles_count_diff = user.tiles_count - user.previous_tiles_count
      user.save
    end
  end

  def process_trending_insight
    TileEntry.all.each do |insight|
      insight.upvotes_diff = insight.upvotes - insight.previous_upvotes
      insight.save
    end
  end
end
