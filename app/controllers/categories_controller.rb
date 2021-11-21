class CategoriesController < ApplicationController
  before_action :category, only: :category_books
  skip_before_action :authenticate_request

  def index
    @categories = Category.select(:name, :slug, :id)
    render json: { data: @categories }
  end

  def books
    render json: category.books.as_json(include: %i[authors category])
  end

  private

  def category
    Category.find_by_slug(params[:slug])
  end
end
