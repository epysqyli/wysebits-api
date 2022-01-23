class SearchRequestsController < ApplicationController
  include Pagy::Backend

  before_action :search_params
  skip_before_action :authenticate_request

  def search_books
    pagy, books = pagy(Book.search_book(search_params[:keywords]))
    resp = books.includes(:authors, :category).as_json(include: %i[authors category])
    render json: { results: resp, pagy: pagy_metadata(pagy) }
  end

  def search_authors
    pagy, authors = pagy(Author.search_author(search_params[:keywords]))
    render json: { results: authors, pagy: pagy_metadata(pagy) }
  end

  private

  def search_params
    params.permit(:keywords, :page_num, search_request: %i[keywords page_num])
  end
end
