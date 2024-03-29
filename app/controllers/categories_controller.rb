class CategoriesController < ApplicationController
  include Pagy::Backend

  before_action :category, except: :index
  skip_before_action :authenticate_request

  def index
    @categories = Category.select(:name, :slug, :id)
    render json: @categories
  end

  def show
    pagy, books = pagy(category.books.includes(:authors, :category).order(tiles_count: :desc))
    resp = BookFormat.authors_category(books)
    render json: { results: resp, pagy: pagy_metadata(pagy) }
  end

  private

  def user
    User.find(params[:user_id])
  end

  def category
    Category.find_by_slug(params[:slug]) || Category.find(params[:id])
  end
end
