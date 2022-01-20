class CategoriesController < ApplicationController
  include Pagy::Backend

  before_action :category, except: :index
  skip_before_action :authenticate_request

  def index
    @categories = Category.select(:name, :slug, :id)
    render json: @categories
  end

  def books
    pagy, books = pagy(category.books.left_joins(:book_tiles).group(:id).order('COUNT(book_tiles.id) DESC'))
    resp = books.as_json(include: %i[authors category])
    render json: { books: resp, pagy: pagy_metadata(pagy) }
  end

  private

  def user
    User.find(params[:user_id])
  end

  def category
    params[:slug] ? Category.find_by_slug(params[:slug]) : Category.find(params[:id])
  end
end
