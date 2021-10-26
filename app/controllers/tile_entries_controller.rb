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
    @tile_entry = TileEntry.new book_id: params[:book_id], content: tile_entry_params[:content]
    if @tile_entry.save
      render json: { data: @tile_entry, status: 'created' }
    else
      render json: { message: 'Tile entry was not created', error_message: @tile_entry.errors.messages }
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
    params.require(:tile_entry).permit(:content)
  end
end
