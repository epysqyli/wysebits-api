class ElasticSearchController < ApplicationController
  skip_before_action :authenticate_request

  def search_books
    elastic_query = ElasticQuery.new
    elastic_query.add_match_to_must 'title', search_params[:title]

    render json: Book.search(elastic_query)
  end

  private

  def search_params
    params.permit(:title)
  end
end
