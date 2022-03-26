class BooksController < ApplicationController
  include Pagy::Backend

  before_action :book, except: :create
  skip_before_action :authenticate_request, only: %i[tile_entries show recommendations]

  def tile_entries
    pagy, entries = pagy(book.all_tile_entries.order(net_votes: :desc).includes(:book_tile))
    resp = BookFormat.json_tiles_user(entries)
    render json: { entries: resp, pagy: pagy_metadata(pagy) }
  end

  def show
    render json: BookFormat.json_authors_category(book)
  end

  def create
    new_book = Book.new
    author = Author.find book_params[:author_id]

    new_book.title = book_params[:title]
    new_book.category_id = book_params[:category_id].to_i
    new_book.ol_author_key = author.key || nil

    new_book.save
    new_book.add_or_replace_author(author)

    if book_params[:book_cover]
      new_book.handle_attachment(book_params[:book_cover])
      new_book.cover_url = url_for(new_book.book_cover)

      new_book.save
    end

    if new_book
      render json: new_book
    else
      render json: { message: 'One or more parameters are causing an error' }
    end
  end

  def update
    book.update!(title: book_params[:title], category_id: book_params[:category_id])

    if book_params[:author_id]
      author = Author.find(book_params[:author_id])
      book.ol_author_key = author.key
      book.add_or_replace_author(author)
    end

    if book_params[:book_cover]
      book.handle_attachment(book_params[:book_cover])
      book.cover_url = url_for(book.book_cover)
      book.save
    end

    render json: book.as_json(include: %i[authors category])
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

  def recommendations
    category = Category.find book.category_id
    recommendations = BookFormat.json_authors_category(category.recommendations(book))
    render json: recommendations
  end

  private

  def book
    Book.includes(:authors, :category).find(params[:id])
  end

  def book_params
    params.permit(:id, :title, :category_id, :book_cover, :author_id)
  end
end
