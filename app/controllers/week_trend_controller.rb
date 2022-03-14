class WeekTrendController < ApplicationController
  before_action :redis
  skip_before_action :authenticate_request

  def index
    render json: { book: trending_book, user: trending_user, insight: trending_insight }, status: :ok
  end

  private

  def redis
    Redis.new
  end

  def trending_book
    JSON.parse(redis.get('trending_book'))
  end

  def trending_user
    JSON.parse(redis.get('trending_user'))
  end

  def trending_insight
    JSON.parse(redis.get('trending_insight'))
  end
end
