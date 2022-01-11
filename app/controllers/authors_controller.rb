class AuthorsController < ApplicationController
  before_action :author, only: :show
  skip_before_action :authenticate_request, only: :show

  def show
    render json: author.books
  end

  def create
    new_author = Author.new full_name: params[:full_name]
    if new_author.save
      render json: new_author
    else
      render json: 'Error in author creation'
    end
  end

  private

  def author
    Author.find(params[:id])
  end

  def author_params
    params.permit(:full_name)
  end
end
