class BookTilesController < ApplicationController
  include Pagy::Backend

  before_action :user, only: %i[index index_no_pagy index_temp_entries create available]
  before_action :book, only: %i[create available]
  before_action :book_tile, only: %i[show destroy]
  skip_before_action :authenticate_request, only: %i[index index_no_pagy show]

  def index
    pagy, user_book_tiles = pagy(BookTile.where(user_id: user.id).preload(:tile_entries)
      .includes({ book: %i[authors category] }).joins(:tile_entries).distinct.order(updated_at: :desc))

    resp = BookTileFormat.entries_book_authors_category(user_book_tiles)
    render json: { tiles: resp, pagy: pagy_metadata(pagy) }
  end

  def nonpaginated
    user_book_tiles = BookTileFormat.entries(user.book_tiles)
    render json: { tiles: user_book_tiles }
  end

  def temporary
    temp_book_tiles = BookTile.distinct.where(user_id: user.id).joins(:temporary_entries)
                              .includes({ book: %i[authors category] }, :tile_entries)

    pagy, temp_book_tiles = pagy(temp_book_tiles.order(created_at: :desc))
    resp = BookTileFormat.entries_book_authors_category(temp_book_tiles)
    render json: { tiles: resp, pagy: pagy_metadata(pagy) }
  end

  def show
    render json: BookTileFormat.entries_book_authors_category_temp(book_tile)
  end

  def create
    existing_book_tile = BookTile.where(user_id: user.id, book_id: book_tile_params[:book_id]).first

    if existing_book_tile.present?
      render json: existing_book_tile
    else
      book_tile = BookTile.new({ book_id: book_tile_params[:book_id], user_id: params[:user_id] })

      if book_tile.save
        book.find_or_create_metric_data

        render json: book_tile
      else
        render json: { message: book_tile.errors.messages }
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

  def destroy_temporary
    book_tile = BookTile.where(user_id: params[:user_id], book_id: params[:id]).first
    book_tile.temporary_entries.each(:destroy)
    render json: book_tile.temporary_entries
  end

  def available
    book_tile = BookTile.where(user_id: user.id).where(book_id: book.id).first

    if book_tile.nil?
      render json: { res: true }
    elsif book_tile.tile_entries.empty?
      render json: { res: true, temporary_entries: book_tile.temporary_entries }
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
