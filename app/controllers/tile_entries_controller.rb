class TileEntriesController < ApplicationController
  before_action :book_tile, only: %i[index create]
  before_action :tile_entry, only: :show
  skip_before_action :authenticate_request, only: %i[top_tiles index show]

  def top_tiles
    @top_three = TileEntry.all.order('upvotes DESC').first(10)
    render json: { data: @top_three.as_json(include: { book_tile: { include: [{ book: { include: :category } }, :user] } }) }
  end

  def index
    @tile_entries = book_tile.tile_entries
    render json: { data: @tile_entries }
  end

  def show
    render json: { data: tile_entry } if tile_entry
  end

  def create
    @first_entry = TileEntry.new book_tile_id: params[:book_tile_id], content: tile_entry_params[:first_entry]

    @second_entry = TileEntry.new book_tile_id: params[:book_tile_id], content: tile_entry_params[:second_entry]

    @third_entry = TileEntry.new book_tile_id: params[:book_tile_id], content: tile_entry_params[:third_entry]

    entries = [@first_entry, @second_entry, @third_entry]

    if entries.each(&:save)
      render json: { data: [@first_entry, @second_entry, @third_entry], status: 'created' }
    else
      render json: { message: 'Tile entry was not created', error_messages: entries.each(&:errors.messages) }
    end
  end

  def update; end

  def destroy; end

  private

  def tile_entry
    TileEntry.find(params[:id])
  end

  def book_tile
    BookTile.find(params[:book_tile_id])
  end

  def tile_entry_params
    params.permit(:first_entry, :second_entry, :third_entry, :book_tile_id, :tile_entry)
  end
end
