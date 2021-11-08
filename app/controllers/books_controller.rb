class BooksController < ApplicationController
  before_action :book, only: %i[tiles show destroy]
  skip_before_action :authenticate_request, only: %i[tiles show]

  def tiles
    render json: { data: book.book_tiles }
  end

  def show
    render json: { data: book.as_json(include: %i[authors category]) }
  end

  def create
    @book = Book.new

    author = Author.find_or_create_author(book_params)

    @book.title = book_params[:title]
    @book.category_id = book_params[:category_id].to_i
    @book.ol_author_key = author.key || nil

    if @book.save
      @book.add_author(author) # fix duplicate author bug

      @book.handle_attachment(book_params[:book_cover])
      @book.cover_url = url_for(@book.book_cover)
      @book.save

      render json: @book
    else
      render json: { message: 'One or more parameters are causing an error' }
    end
  end

  def update; end

  def destroy
    attachment_id = book.book_cover.attachment.id
    if book.destroy
      ActiveStorage::Attachment.find(attachment_id).purge
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
