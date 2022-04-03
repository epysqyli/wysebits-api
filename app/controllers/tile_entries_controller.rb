class TileEntriesController < ApplicationController
  include Pagy::Backend

  before_action :book, only: :book_index
  before_action :book_tile, only: %i[create]
  before_action :tile_entry, only: %i[show update]
  before_action :user, only: %i[index commented_entries]
  skip_before_action :authenticate_request, only: %i[index book_index show commented_entries]

  def index
    pagy, user_entries = pagy(user.all_tile_entries.order(created_at: :desc))
    resp = TileEntryFormat.json_booktile_book_user(user_entries)
    render json: { entries: resp, pagy: pagy_metadata(pagy) }
  end

  def book_index
    user_book_entries = user.all_book_insights(book).order(upvotes: :desc)
    resp = TileEntryFormat.json_booktile_book_user(user_book_entries)
    render json: resp
  end

  def show
    render json: { data: tile_entry }
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

  def commented_entries
    entries_ids = Comment.where(user: user, commentable_type: 'TileEntry').distinct.pluck(:commentable_id)
    pagy, entries = pagy(TileEntry.where(id: entries_ids).order(created_at: :desc))
    resp = TileEntryFormat.json_booktile_book_user(entries)
    render json: { entries: resp, pagy: pagy_metadata(pagy) }
  end

  private

  def user
    params[:user_id] ? User.find(params[:user_id]) : User.find(params[:id])
  end

  def tile_entry
    TileEntry.find(params[:id])
  end

  def book_tile
    BookTile.find(params[:book_tile_id])
  end

  def book
    Book.find(params[:id])
  end

  def tile_entry_params
    params.permit(:first_entry, :second_entry, :third_entry, :book_tile_id, :tile_entry, :id, :content)
  end
end
