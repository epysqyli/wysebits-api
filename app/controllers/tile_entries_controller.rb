class TileEntriesController < ApplicationController
  def index; end

  def show; end

  def create; end

  def update; end

  def destroy; end

  private

  def book_tile
    BookTile.find(params[:book_tile_id])
  end

  def tile_entry_params
    params.require(:tile_entry).permit(:content)
  end
end
