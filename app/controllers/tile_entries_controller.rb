class TileEntriesController < ApplicationController
  include Pagy::Backend

  before_action :book_tile, only: %i[index create]
  before_action :tile_entry, only: %i[show update]
  before_action :user, only: :all_user_entries
  skip_before_action :authenticate_request, only: %i[top_tiles index show all_user_entries]

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
      book_tile.temporary_entries.each(&:destroy) if book_tile.temporary_entries.present?
      render json: { data: [@first_entry, @second_entry, @third_entry], status: 'created' }
    else
      render json: { message: 'Tile entry was not created', error_messages: entries.each(&:errors.messages) }
    end
  end

  def update
    if tile_entry.update(tile_entry_params)
      render json: { data: tile_entry }
    else
      render json: { message: 'error' }
    end
  end

  def destroy; end

  def all_user_entries
    pagy, user_entries = pagy(user.all_tile_entries.order(updated_at: :desc))
    resp = user_entries.as_json(include: { book_tile: { include: [:book, { user: { only: %i[id username] } }] } })
    render json: { entries: resp, pagy: pagy_metadata(pagy) }
  end

  private

  def user
    User.find(params[:user_id])
  end

  def tile_entry
    TileEntry.find(params[:id])
  end

  def book_tile
    BookTile.find(params[:book_tile_id])
  end

  def tile_entry_params
    params.permit(:first_entry, :second_entry, :third_entry, :book_tile_id, :tile_entry, :id, :content)
  end
end
