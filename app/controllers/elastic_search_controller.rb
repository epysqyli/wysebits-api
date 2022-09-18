class ElasticSearchController < ApplicationController
  skip_before_action :authenticate_request

  def search_books
    elastic_query = ElasticQuery.new
    elastic_query.build_query(params[:search_query])

    render json: Book.search(elastic_query)
  end
end
