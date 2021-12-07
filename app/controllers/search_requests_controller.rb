class SearchRequestsController < ApplicationController
  include Pagy::Backend
  skip_before_action :authenticate_request, only: :search_books

  def search_books
    search_terms = JSON.parse(search_params[:keywords])
    results = Book.pagy_search(search_terms)
    pagy, resp = pagy_elasticsearch_rails(results, items: 10)

    if resp.empty?
      render json: { message: 'No results. Do you want to create this book record?' }
    else
      render json: { results: resp, pagy: pagy }
    end
  end

  private

  def search_params
    params.permit(:keywords, search_request: [:keywords])
  end
end
