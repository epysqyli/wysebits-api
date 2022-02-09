class UpvotedEntriesController < ApplicationController
  before_action :user
  before_action :tile_entry, only: %i[create destroy]

  def index
    render json: { upvoted_entries: user.upvoted_entries.select(:id) }
  end

  def create
    if user.upvoted_entries.include?(tile_entry)
      render json: { message: 'Entry already upvoted' }
    else
      user.upvote(tile_entry)
      book = tile_entry.book_tile.book
      metric_data = book.find_or_create_metric_data
      metric_data.upvotes_count += 1
      metric_data.save
      render json: { message: 'Upvote submitted' }
    end
  end

  def destroy
    user.remove_upvote(tile_entry)
    book = tile_entry.book_tile.book
    metric_data = book.find_or_create_metric_data
    metric_data.upvotes_count -= 1
    metric_data.save
    render json: { message: 'Upvote removed' }
  end

  private

  def user
    User.find params[:user_id]
  end

  def tile_entry
    TileEntry.find upvote_params[:id]
  end

  def upvote_params
    params.permit(:id, :user_id, upvoted_entry: %i[id user_id])
  end
end
