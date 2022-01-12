class BooksController < ApplicationController
  include Pagy::Backend

  before_action :book, only: %i[tile_entries show update destroy]
  skip_before_action :authenticate_request, only: %i[tile_entries show]

  def tile_entries
    pagy, all_tile_entries = pagy(book.all_tile_entries.order(net_votes: :desc))
    resp = all_tile_entries.as_json(include: [book_tile: { include: [user: { only: %i[username id] }] }])
    render json: { entries: resp, pagy: pagy_metadata(pagy) }
  end

  def show
    render json: book.as_json(include: %i[authors category])
  end

  def create
    @book = Book.new
    author = Author.find book_params[:author_id]

    @book.title = book_params[:title]
    @book.category_id = book_params[:category_id].to_i
    @book.ol_author_key = author.key || nil

    @book.add_or_replace_author(author)

    if @book.save && book_params[:book_cover]
      @book.handle_attachment(book_params[:book_cover])
      @book.cover_url = url_for(@book.book_cover)

      @book.save
    end

    if @book
      render json: @book
    else
      render json: { message: 'One or more parameters are causing an error' }
    end
  end

  def update
    @book = book
    partial_book_params = { title: book_params[:title], category_id: book_params[:category_id] }

    if book_params[:author_id]
      author = Author.find(book_params[:author_id])
      @book.add_or_replace_author(author)
    end

    if @book.update(partial_book_params) && book_params[:book_cover]
      @book.handle_attachment(book_params[:book_cover])
      @book.cover_url = url_for(book.book_cover)
      @book.save

      render json: @book.as_json(include: %i[authors category])
    else
      render json: { message: 'error' }
    end
  end

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
    params.permit(:id, :title, :category_id, :book_cover, :author_id)
  end
end
