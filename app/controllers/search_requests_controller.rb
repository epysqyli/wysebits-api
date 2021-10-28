class SearchRequestsController < ApplicationController
  skip_before_action :authenticate_request, only: :search_books

  def search_books
    search_terms = JSON.parse(search_params[:keywords])
    res = Book.search(search_terms)

    # integrate results with openlibrar's data dump instead of slow/unscaleable OL api

    # check if selected book is present in the wysebits db - if not, create it

    # to every book must be assigned at least one author and the category

    if res.empty?
      render json: { message: 'No book results. Do you want to manually create this book record?' }
    else
      render json: { data: res.as_json(include: %i[authors category]) }
    end
  end

  private

  def search_params
    params.permit(:keywords)
  end
end
