class SearchRequestsController < ApplicationController
  def search_books
    search_terms = JSON.parse(search_params[:keywords])
    res = Book.search(search_terms)

    if res.empty?
      render json: { message: 'No results. Do you want to create this book record?' }
    else
      render json: res.as_json(include: %i[authors category])
    end
  end

  private

  def search_params
    params.permit(:keywords, search_request: [:keywords])
  end
end
