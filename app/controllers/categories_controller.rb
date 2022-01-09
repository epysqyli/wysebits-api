class CategoriesController < ApplicationController
  include Pagy::Backend

  before_action :category, except: :index
  before_action :user, only: :custom_feed
  skip_before_action :authenticate_request

  def index
    @categories = Category.select(:name, :slug, :id)
    render json: @categories
  end

  def books
    pagy, books = pagy(category.books)
    books = books.sort_by { |book| book.book_tiles.size }.reverse
    resp = books.as_json(include: %i[authors category])
    render json: { books: resp, pagy: pagy_metadata(pagy) }
  end

  def recommendations
    books = category.books.order(updated_at: :desc).limit(50)
    recommendations = books.sort_by(&:rank_score).reverse.slice(0, 4)
    recommendations = recommendations.as_json(include: %i[authors category])
    render json: recommendations
  end

  def custom_feed; end

  private

  def user
    User.find(params[:user_id])
  end

  def category
    params[:slug] ? Category.find_by_slug(params[:slug]) : Category.find(params[:id])
  end
end
