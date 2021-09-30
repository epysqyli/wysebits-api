class BooksController < ApplicationController
  before_action :book, only: :tiles
  skip_before_action :authenticate_request

  def tiles
    render json: { data: book.book_tiles }
  end

  private

  def book
    Book.find(params[:id])
  end
end
