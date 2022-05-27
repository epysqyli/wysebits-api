class SearchRequestsController < ApplicationController
  include Pagy::Backend

  before_action :category, only: :search_within_category
  before_action :author, only: :search_within_author
  before_action :user, only: %i[search_within_fav_books search_within_creator_books]
  skip_before_action :authenticate_request

  def search_books
    pagy, books = pagy(Book.search(search_params[:keywords]).with_pg_search_highlight)
    resp = BookFormat.authors_category(books.includes(:authors, :category))
    render json: { results: resp, pagy: pagy_metadata(pagy) }
  end

  def search_books_from_authors
    pagy, books = pagy(Book.where(id: Author.search(search_params[:keywords]).flat_map(&:book_ids)))
    resp = BookFormat.authors_category(books.includes(:authors, :category))
    render json: { results: resp, pagy: pagy_metadata(pagy) }
  end

  def search_authors
    authors = Author.search(search_authors_params[:author_full_name])
    render json: { results: authors }
  end

  def search_books_authors
    results = Book.search(book_author_search_params[:book_keywords])
                  .where(id: Author.search(book_author_search_params[:author_keywords])
                  .flat_map(&:book_ids)).with_pg_search_highlight
    pagy, books = pagy(results)
    resp = BookFormat.authors_category(books.includes(:authors, :category))
    render json: { results: resp, pagy: pagy_metadata(pagy) }
  end

  def search_within_category
    pagy, books = pagy(Book.where(category: category).search(search_params[:keywords]))
    resp = BookFormat.authors_category(books.includes(:authors, :category))
    render json: { results: resp, pagy: pagy_metadata(pagy) }
  end

  def search_within_author
    pagy, books = pagy(author.books.search(search_params[:keywords]))
    resp = BookFormat.authors_category(books.includes(:authors, :category))
    render json: { results: resp, pagy: pagy_metadata(pagy) }
  end

  def search_within_fav_books
    pagy, search_results = pagy(user.liked_books.search(search_params[:keywords]).includes(book: %i[authors category]))
    books = FavBook.preload(:book).where(book: [search_results], user: user)
    resp = BookFormat.book_authors_category(books)
    render json: { results: resp, pagy: pagy_metadata(pagy) }
  end

  def search_within_book_tiles
    user_book_tiles = BookTile.preload(:tile_entries).where(user: user).joins(:tile_entries).distinct
    book_search_set = Book.where(id: user_book_tiles.map(&:book_id)).search(search_params[:keywords])
    book_tiles = BookTile.where(user: user, book: book_search_set.map(&:id)).preload(:tile_entries)
                         .includes({ book: %i[authors category] }).joins(:tile_entries).distinct

    pagy, paged_book_tiles = pagy(book_tiles)
    resp = BookTileFormat.entries_book_authors_category(paged_book_tiles)
    render json: { tiles: resp, pagy: pagy_metadata(pagy) }
  end

  private

  def search_params
    params.permit(:keywords, :page, :user_id, search_request: %i[keywords page])
  end

  def search_authors_params
    params.permit(:author_full_name)
  end

  def book_author_search_params
    params.permit(:book_keywords, :author_keywords, :page, :user_id,
                  search_request: %i[book_keywords author_keywords page])
  end

  def author
    Author.find(params[:author_id])
  end

  def category
    Category.find_by_slug(params[:category_slug])
  end

  def user
    User.find(params[:user_id])
  end
end
