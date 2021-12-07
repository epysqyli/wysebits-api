class SearchRequestsController < ApplicationController
  skip_before_action :authenticate_request, only: :search_books

  def search_books
    search_terms = JSON.parse(search_params[:keywords])
    # from = JSON.parse(search_params[:from])
    results = Book.search(search_terms)

    if results.empty?
      render json: { message: 'No results. Do you want to create this book record?' }
    else
      render json: results
    end
  end

  private

  def search_params
    params.permit(:keywords, :from, search_request: [:keywords])
  end
end
