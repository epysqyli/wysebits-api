class ElasticSearchController < ApplicationController
  skip_before_action :authenticate_request

  def search_books
    elastic_query = ElasticRequest.new
    elastic_query.build_query(params[:search_request])

    render json: Book.search(elastic_query, params[:page])
  end
end
