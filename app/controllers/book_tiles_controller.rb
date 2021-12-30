class BookTilesController < ApplicationController
  include Pagy::Backend

  before_action :user, only: %i[index index_no_pagy create available?]
  before_action :book, only: %i[create available?]
  before_action :book_tile, only: %i[show destroy]
  skip_before_action :authenticate_request, only: %i[index index_no_pagy show]

  def index
    pagy, user_book_tiles = pagy(user.book_tiles.order(updated_at: :desc))
    resp = user_book_tiles.as_json(include: [:tile_entries, { book: { include: %i[authors category] } }])
    render json: { tiles: resp, pagy: pagy_metadata(pagy) }
  end

  def index_no_pagy
    user_book_tiles = user.book_tiles.as_json(include: :tile_entries)
    render json: { tiles: user_book_tiles }
  end

  def show
    render json: book_tile.as_json(include: [:tile_entries, { book: { include: %i[authors category] } },
                                             :temporary_entries])
  end

  def create
    existing_book_tile = user.book_tiles.any? { |book_tile| book_tile.book_id == book_tile_params[:book_id] }

    if existing_book_tile
      render json: BookTile.find(book_tile_params[:book_id])
    else
      @book_tile = BookTile.new({ book_id: book_tile_params[:book_id], user_id: params[:user_id] })

      if @book_tile.save
        user.book_tiles << @book_tile
        book.book_tiles << @book_tile

        # handle metric_data creation if not present
        book.find_or_create_metric_data

        render json: @book_tile
      else
        render json: { message: @book_tile.errors.messages }
      end
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

  def available?
    book_tile = user.book_tiles.find { |tile| tile.book_id == book.id }

    if book_tile.nil?
      render json: { res: true }
    elsif book_tile.tile_entries.empty?
      render json: { res: true }
    else
      render json: { res: false, existing_book_tile: book_tile }
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
