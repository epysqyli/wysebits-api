class DownvotedEntriesController < ApplicationController
  before_action :user
  before_action :tile_entry, only: %i[create destroy]

  def index
    render json: { downvoted_entries: user.downvoted_entries.select(:id) }
  end

  def create
    if user.downvoted_entries.include?(tile_entry)
      render json: { message: 'Entry already downvoted' }
    else
      user.downvote(tile_entry)
      book = tile_entry.book_tile.book
      book.find_or_create_metric_data.update_book_metrics('downvotes', :increase)
      render json: { message: 'Downvote submitted' }
    end
  end

  def destroy
    user.remove_downvote(tile_entry)
    book = tile_entry.book_tile.book
    book.find_or_create_metric_data.update_book_metrics('downvotes', :decrease)
    render json: { message: 'Downvote removed' }
  end

  private

  def user
    User.find params[:user_id]
  end

  def tile_entry
    TileEntry.find downvote_params[:id]
  end

  def downvote_params
    params.permit(:id, :user_id, downvoted_entry: %i[id user_id])
  end
end
