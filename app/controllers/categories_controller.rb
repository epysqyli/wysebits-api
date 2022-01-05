class CategoriesController < ApplicationController
  include Pagy::Backend

  before_action :category, only: :category_books
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

  private

  def user
    User.find(params[:user_id])
  end

  def category
    Category.find_by_slug(params[:slug])
  end
end
