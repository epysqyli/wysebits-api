class BooksController < ApplicationController
  before_action :book, only: %i[tiles show destroy]
  skip_before_action :authenticate_request, only: %i[tiles show]

  def tiles
    render json: { data: book.book_tiles }
  end

  def show
    render json: { data: book }
  end

  def create
    @book = Book.new

    # define author to assign the book to --> move it to the model
    full_name = Author.arel_table[:full_name]
    full_name_param = book_params[:author_full_name].split.map(&:capitalize).join(' ')
    results = Author.where(full_name.matches("%#{full_name_param}%"))

    new_author = if results.empty?
                   Author.create! full_name: full_name_param
                 else
                   results.max_by { |author| author.books.size }
                 end

    @book.title = book_params[:title]
    @book.category_id = book_params[:category_id]
    @book.ol_key = nil
    @book.ol_author_key = new_author.key || nil

    if @book.save
      @book.add_author(new_author)
      @book.book_cover.attach(book_params[:book_cover])
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
    params.permit(:title, :category_id, :book_cover, :author_full_name)
  end
end
