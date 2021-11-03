class SearchRequestsController < ApplicationController
  # skip_before_action :authenticate_request

  def search_books
    search_terms = JSON.parse(search_params[:keywords])
    res = Book.search(search_terms)

    if res.empty?
      render json: { message: 'No results. Do you want to manually create this book record?' }
    else
      render json: { data: res.as_json(include: %i[authors category]) }
    end
  end

  private

  def search_params
    params.permit(:keywords, search_request: [:keywords])
  end
end
