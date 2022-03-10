class WeekTrendController < ApplicationController
  skip_before_action :authenticate_request

  def index
    render json: { book: trending_book, user: json_user, insight: trending_insight }, status: :ok
  end

  private

  def trending_book
    Book.order(tiles_count_diff: :desc).first
  end

  def trending_user
    User.order(tiles_count_diff: :desc).first
  end

  def json_user
    trending_user.as_json(only: %i[username tiles_count_diff avatar_url])
  end

  def trending_insight
    TileEntry.order(upvotes_diff: :desc).first
  end
end
