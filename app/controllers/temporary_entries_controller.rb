class TemporaryEntriesController < ApplicationController
  before_action :temporary_entry, only: %i[show update]
  before_action :book_tile, only: %i[index create]

  def index; end

  def show
    render json: temporary_entry
  end

  def create
    new_temp_entry = TemporaryEntry.new book_tile_id: params[:book_tile_id], content: temp_entry_params[:content]

    if new_temp_entry.save
      render json: new_temp_entry
    else
      render json: 'An error occurred in the creation'
    end
  end

  def update
    if temporary_entry.update(temp_entry_params)
      render json: temporary_entry
    else
      render json: 'Something went wrong'
    end
  end

  private

  def temporary_entry
    TemporaryEntry.find(params[:id])
  end

  def book_tile
    BookTile.find(params[:book_tile_id])
  end

  def temp_entry_params
    params.permit(:content, :book_tile_id, :temporary_entry)
  end
end
