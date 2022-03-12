class StatsController < ApplicationController
  before_action :user, only: :user_stats
  skip_before_action :authenticate_request

  def user_stats
    render json: { entries: TileEntryFormat.json_booktile_book_authors_category_user(user.entries_stats) }
  end

  def trending; end

  private

  def user
    User.find params[:id]
  end
end
