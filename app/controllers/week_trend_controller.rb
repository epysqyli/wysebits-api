class WeekTrendController < ApplicationController
  skip_before_action :authenticate_request

  def index
    render json: { book: trending_book, user: trending_user, insight: trending_insight }, status: :ok
  end

  private

  def trending_book
    Book.includes(%i[authors category]).order(tiles_count_diff: :desc).first.as_json(include: %i[authors category])
  end

  def trending_user
    User.order(tiles_count_diff: :desc).first.as_json(only: %i[username tiles_count_diff avatar_url])
  end

  def trending_insight
    TileEntry.includes(book_tile: %i[user book]).order(upvotes_diff: :desc).first
             .as_json(include: { book_tile: { include: [:book, { user: { only: %i[id username] } }] } })
  end
end
