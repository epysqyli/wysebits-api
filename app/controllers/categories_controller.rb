class CategoriesController < ApplicationController
  skip_before_action :authenticate_request, only: :index

  def index
    @categories = Category.select(:name, :slug)
    render json: { data: @categories }
  end
end
