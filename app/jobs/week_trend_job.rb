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
      book.previous_tiles_count = book.tiles_count
      book.save
    end

    candidate_trending_book = Book.order(tiles_count_diff: :desc).first

    trending_book = if !candidate_trending_book.tiles_count_diff.zero?
                      BookFormat.authors_category(
                        Book.includes(%i[authors category]).order(tiles_count_diff: :desc).first
                      )
                    else
                      BookFormat.authors_category(
                        Book.includes(%i[authors category]).order(tiles_count: :desc).first
                      )
                    end

    cache('trending_book', trending_book)

    books.each do |book|
      book.tiles_count_diff = 0
      book.save
    end
  end

  def process_trending_user
    users = User.distinct.where(id: BookTile.pluck(:user_id))
    users.each do |user|
      user.tiles_count_diff = user.tiles_count - user.previous_tiles_count
      user.previous_tiles_count = user.tiles_count
      user.save
    end

    candidate_trending_user = User.order(tiles_count_diff: :desc).first

    trending_user = if !candidate_trending_user.tiles_count_diff.zero?
                      UserFormat.username_tiles_diff_avatar(candidate_trending_user)
                    else
                      UserFormat.username_tiles_diff_avatar(User.order(tiles_count: :desc).first)
                    end

    cache('trending_user', trending_user)

    users.each do |user|
      user.tiles_count_diff = 0
      user.save
    end
  end

  def process_trending_insight
    TileEntry.all.each do |insight|
      insight.upvotes_diff = insight.upvotes - insight.previous_upvotes
      insight.previous_upvotes = insight.upvotes
      insight.save
    end

    candidate_insight = TileEntry.order(upvotes_diff: :desc).first

    trending_insight = if !candidate_insight.upvotes_diff.zero?
                         TileEntryFormat.booktile_book_user(
                           TileEntry.includes(book_tile: %i[user book]).order(upvotes_diff: :desc).first
                         )
                       else
                         TileEntryFormat.booktile_book_user(
                           TileEntry.includes(book_tile: %i[user book]).order(net_votes: :desc).first
                         )
                       end

    cache('trending_insight', trending_insight)

    TileEntry.all.each do |insight|
      insight.upvotes_diff = 0
      insight.save
    end
  end
end
