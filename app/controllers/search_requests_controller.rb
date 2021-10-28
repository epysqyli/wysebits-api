class SearchRequestsController < ApplicationController
  skip_before_action :authenticate_request, only: :search_books

  def search_books
    search_terms = JSON.parse(search_params[:keywords])
    res = Book.search(search_terms)

    # integrate results with openlibrary api
    # check if selected book is present in db - if not, create
    # if no book matches the results, user creates a new one

    # assigning author to a book should follow a similar logic

    if res.empty?
      render json: { message: 'No book results matching these search terms' }
    else
      render json: { data: res.as_json(include: %i[authors category]) }
    end
  end

  private

  def search_params
    params.permit(:keywords)
  end
end
