class FavTileEntriesController < ApplicationController
  include Pagy::Backend

  before_action :user
  before_action :tile_entry, only: %i[create destroy]

  def index
    pagy, fav_tile_entries = pagy(user.fav_tile_entries.order(created_at: :desc)
    .includes({ tile_entry: [{ book_tile: %i[user book] }] }))

    resp = fav_tile_entries.as_json(include: [tile_entry: { include:
      [book_tile:
        { include:
          [{ user: { only: %i[username id] } }, :book] }] }]).map { |item| item['tile_entry'] }
    render json: { tile_entries: resp, pagy: pagy_metadata(pagy) }
  end

  def nonpaginated
    entries = user.fav_tile_entries.select(user.fav_tile_entries.arel_table['tile_entry_id'].as('id'))
    render json: { tile_entries: entries }
  end

  def create
    user.add_to_fav_tile_entries(tile_entry)
    book = tile_entry.book_tile.book
    metric_data = book.find_or_create_metric_data
    metric_data.fav_entries_count += 1
    metric_data.save
    if user.fav_tile_entries.include?(tile_entry)
      render json: { message: 'insight added to favorites' }
    else
      render json: { message: 'error' }
    end
  end

  def destroy
    user.remove_from_fav_tile_entries(tile_entry)
    book = tile_entry.book_tile.book
    metric_data = book.find_or_create_metric_data
    metric_data.fav_entries_count -= 1
    metric_data.save
    if user.fav_tile_entries.include?(tile_entry)
      render json: { message: 'error' }
    else
      render json: { message: 'insight removed from favorites' }
    end
  end

  private

  def user
    User.find params[:user_id]
  end

  def tile_entry
    TileEntry.find fav_entry_params[:id]
  end

  def fav_entry_params
    params.permit(:id, :user_id, fav_tile_entry: %i[id user_id])
  end
end
