class FollowersController < ApplicationController
  include Pagy::Backend
  before_action :user

  def index
    pagy, user_followers = pagy(user.passive_relationships.order(created_at: :desc)
    .includes({ follower: [{ book_tiles: :tile_entries }] }))

    resp = user_followers.as_json(include:
      { follower: { only: %i[username id avatar_url], include: { book_tiles: { include: :tile_entries } } } })
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
