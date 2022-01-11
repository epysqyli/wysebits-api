class AuthorsController < ApplicationController
  before_action :author, only: :show
  skip_before_action :authenticate_request

  def index; end

  def show
    render json: author.books
  end

  private

  def author
    Author.find(params[:id])
  end

  def author_params
    # params.permit
  end
end
