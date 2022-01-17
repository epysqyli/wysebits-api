class TileEntriesController < ApplicationController
  include Pagy::Backend

  before_action :book_tile, only: %i[create]
  before_action :tile_entry, only: %i[show update]
  before_action :user, only: %i[user_feed custom_feed all_user_entries]
  skip_before_action :authenticate_request, only: %i[all_user_entries show guest_feed]

  def guest_feed
    pagy, entries = pagy(TileEntry.all.order(updated_at: :desc))
    resp = entries.as_json(include: { book_tile: { include: [{ book: { include: %i[authors category] } },
                                                             { user: { only: %i[username id] } }] } })
    render json: { entries: resp, pagy: pagy_metadata(pagy) }
  end

  def user_feed
    pagy, entries = pagy(TileEntry.other_user_entries(user).order(updated_at: :desc))
    resp = entries.as_json(include: { book_tile: { include: [{ book: { include: %i[authors category] } },
                                                             { user: { only: %i[username id] } }] } })
    render json: { entries: resp, pagy: pagy_metadata(pagy) }
  end

  def custom_feed
    fav_categories = user.fav_categories.map(&:id)
    entries = TileEntry.where(book_tile_id: BookTile.where(book_id: Book.where(category_id: fav_categories)))
    pagy, entries = pagy(entries.order(updated_at: :desc))

    entries = entries.as_json(include: { book_tile: { include: [{ book: { include: %i[authors category] } },
                                                                { user: { only: %i[username id] } }] } })

    render json: { entries: entries, pagy: pagy_metadata(pagy) }
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

  def all_user_entries
    pagy, user_entries = pagy(user.all_tile_entries.order(created_at: :desc))
    resp = user_entries.as_json(include: { book_tile: { include: [:book, { user: { only: %i[id username] } }] } })
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

  def tile_entry_params
    params.permit(:first_entry, :second_entry, :third_entry, :book_tile_id, :tile_entry, :id, :content)
  end
end
