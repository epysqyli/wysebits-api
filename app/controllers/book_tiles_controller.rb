class BookTilesController < ApplicationController
  before_action :user, only: %i[index create]
  before_action :book, only: :create
  skip_before_action :authenticate_request, only: %i[index show]

  def tiles_index
    @book_tiles = BookTile.all
    render json: @book_tiles
  end

  def index
    @book_tiles = user.book_tiles
    render json: @book_tiles
  end

  def show
    book_tile = BookTile.find(params[:id])
    render json: book_tile
  end

  def create
    @book_tile = BookTile.new({ book_id: book_tile_params[:book_id], user_id: params[:user_id] })
    if @book_tile.save
      # integrate front-end flow for book_tile creation
      user.book_tiles << @book_tile
      book.book_tiles << @book_tile
      render json: @book_tile
    else
      render json: { message: @book_tile.errors.messages }
    end
  end

  def update; end

  def destroy; end

  private

  def user
    User.find(params[:user_id])
  end

  def book
    # find the book to which the tile belongs via front-end logic
    Book.find(book_tile_params[:book_id])
  end

  def book_tile_params
    params.permit(:book_id, :user_id)
  end
end
