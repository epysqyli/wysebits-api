class TileEntriesController < ApplicationController
  before_action :book_tile, only: %i[index create]
  before_action :tile_entry, only: :show
  skip_before_action :authenticate_request, only: %i[index show]

  def index
    @tile_entries = book_tile.tile_entries
    render json: { data: @tile_entries }
  end

  def show
    render json: { data: tile_entry } if tile_entry
  end

  def create; end

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
