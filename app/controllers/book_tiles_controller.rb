class BookTilesController < ApplicationController
  before_action :user, only: %i[index create]
  before_action :book, only: :create
  before_action :book_tile, only: %i[show destroy]
  skip_before_action :authenticate_request, only: %i[index show]

  def tiles_index
    book_tiles = BookTile.all
    render json: book_tiles
  end

  def index
    user_book_tiles = user.book_tiles
    book_tiles = user_book_tiles.as_json(include: [:tile_entries, { book: { include: %i[authors category] } }])
    render json: book_tiles
  end

  def show
    render json: book_tile
  end

  def create
    @book_tile = BookTile.new({ book_id: book_tile_params[:book_id], user_id: params[:user_id] })
    if @book_tile.save
      user.book_tiles << @book_tile
      book.book_tiles << @book_tile
      render json: @book_tile
    else
      render json: { message: @book_tile.errors.messages }
    end
  end

  def update; end

  def destroy
    if book_tile.destroy
      render json: { message: 'Book_tile deleted from database', status: 'success' }
    else
      render json: { message: 'Not possible to process the request' }
    end
  end

  private

  def user
    User.find(params[:user_id])
  end

  def book
    Book.find(book_tile_params[:book_id])
  end

  def book_tile
    BookTile.find(params[:id])
  end

  def book_tile_params
    params.permit(:book_id, :user_id)
  end
end
