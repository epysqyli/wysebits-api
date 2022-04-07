class FollowersController < ApplicationController
  include Pagy::Backend
  before_action :user

  def index
    pagy, user_followers = pagy(user.passive_relationships.order(created_at: :desc)
    .includes({ follower: [{ book_tiles: :tile_entries }] }))

    resp = FollowFormat.follow_booktile_entries_follower(user_followers)
    render json: { followers: resp, pagy: pagy_metadata(pagy) }
  end

  def nonpaginated
    render json: user.followers.select(:id)
  end

  private

  def user
    User.find params[:user_id]
  end
end
