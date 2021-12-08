class SearchRequestsController < ApplicationController
  skip_before_action :authenticate_request, only: :search_books

  def search_books
    search_terms = JSON.parse(search_params[:keywords])
    page_num = JSON.parse(search_params[:page_num])
    from = page_num == 1 ? 0 : page_num * 20
    results = Book.search(search_terms, from)

    if results.empty?
      render json: { message: 'No results. Do you want to create this book record?' }
    else
      render json: { results: results, page_num: page_num }
    end
  end

  private

  def search_params
    params.permit(:keywords, :page_num, search_request: [:keywords])
  end
end
