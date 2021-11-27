class SearchRequestsController < ApplicationController
  skip_before_action :authenticate_request, only: :search_books

  def search_books
    search_terms = JSON.parse(search_params[:keywords])
    res = Book.search(search_terms)

    if res.empty?
      render json: { message: 'No results. Do you want to create this book record?' }
    else
      render json: res
    end
  end

  private

  def search_params
    params.permit(:keywords, search_request: [:keywords])
  end
end
