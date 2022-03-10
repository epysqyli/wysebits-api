class WeekTrendController < ApplicationController
  skip_before_action :authenticate_request

  def index
    render json: { book: trending_book, user: trending_user, insight: trending_insight }, status: :ok
  end

  private

  def trending_book
    Book.order(tiles_count_diff: :desc).first
  end

  def trending_user
    User.order(tiles_count_diff: :desc).first
  end

  def trending_insight
    TileEntry.order(upvotes_diff: :desc).first
  end
end
