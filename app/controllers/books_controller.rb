class BooksController < ApplicationController
  before_action :book, only: :tiles
  skip_before_action :authenticate_request, only: %i[tiles show]

  def tiles
    render json: { data: book.book_tiles }
  end

  def search(keywords)
    res = Book.search(keywords)
    if res.empty
      render json: { message: 'No book results matching these search terms' }
    else
      render json: { data: res }
    end
  end

  def show
    render json: { data: book }
  end

  def create
    @book = Book.new(book_params)
    if @book.save
      render json: @book
    else
      render json: { message: 'One or more parameters are causing an error' }
    end
  end

  def update; end

  def destroy
    if book.destroy
      render json: { message: 'Book deleted from database', status: 'success' }
    else
      render json: { message: 'Not possible to process the request' }
    end
  end

  private

  def book
    Book.find(params[:id])
  end

  def book_params
    params.require(:book).permit(:title, :release_date, :category_id)
  end
end
