class SearchRequestsController < ApplicationController
  include Pagy::Backend

  before_action :search_params
  before_action :category, only: :search_within_category
  before_action :user, only: %i[search_within_fav_books search_within_creator_books]
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

  def search_within_creator_books
    user_book_tiles = BookTile.preload(:tile_entries).where(user: user).joins(:tile_entries).distinct
    book_search_set = Book.where(id: user_book_tiles.map(&:book_id)).search(search_params[:keywords])
    book_tiles = BookTile.where(user: user, book: book_search_set.map(&:id)).preload(:tile_entries)
                         .includes({ book: %i[authors category] }).joins(:tile_entries).distinct

    pagy, paged_book_tiles = pagy(book_tiles)
    resp = BookTileFormat.json_entries_book_authors_category(paged_book_tiles)
    render json: { tiles: resp, pagy: pagy_metadata(pagy) }
  end

  private

  def search_params
    params.permit(:keywords, :page, :user_id, search_request: %i[keywords page])
  end

  def category
    Category.find_by_slug(params[:category_slug])
  end

  def user
    User.find(params[:user_id])
  end
end
