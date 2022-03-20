class SearchRequestsController < ApplicationController
  include Pagy::Backend

  before_action :search_params
  before_action :category, only: :search_within_category
  before_action :user, only: :search_within_fav_books
  skip_before_action :authenticate_request

  def search_books
    pagy, books = pagy(Book.search(search_params[:keywords]).with_pg_search_highlight)
    resp = BookFormat.json_authors_category(books.includes(:authors, :category))
    render json: { results: resp, pagy: pagy_metadata(pagy) }
  end

  def search_authors
    pagy, authors = pagy(Author.search(search_params[:keywords]))
    render json: { results: authors, pagy: pagy_metadata(pagy) }
  end

  def search_within_category
    pagy, books = pagy(Book.where(category: category).search(search_params[:keywords]))
    resp = BookFormat.json_authors_category(books.includes(:authors, :category))
    render json: { results: resp, pagy: pagy_metadata(pagy) }
  end

  def search_within_fav_books
    pagy, search_results = pagy(user.liked_books.search(search_params[:keywords]).includes(book: %i[authors category]))
    books = FavBook.preload(:book).where(book: [search_results], user: user)
    resp = BookFormat.json_book_authors_category(books)
    render json: { results: resp, pagy: pagy_metadata(pagy) }
  end

  private

  def search_params
    params.permit(:keywords, :page_num, search_request: %i[keywords page_num])
  end

  def category
    Category.find_by_slug(params[:category_slug])
  end

  def user
    User.find(params[:user_id])
  end
end
