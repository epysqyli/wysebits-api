class WeekTrendController < ApplicationController
  skip_before_action :authenticate_request

  def index
    render json: { book: trending_book, user: trending_user, insight: trending_insight }, status: :ok
  end

  private

  def trending_book
    BookFormat.json_authors_category(Book.includes(%i[authors category]).order(tiles_count_diff: :desc).first)
  end

  def trending_user
    User.order(tiles_count_diff: :desc).first.as_json(only: %i[username tiles_count_diff avatar_url])
  end

  def trending_insight
    TileEntryFormat.json_booktile_book_user(TileEntry.includes(book_tile: %i[user book]).order(upvotes_diff: :desc).first)
  end
end
