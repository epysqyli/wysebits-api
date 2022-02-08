class FollowingController < ApplicationController
  include Pagy::Backend
  before_action :user

  def index
    pagy, user_following = pagy(user.active_relationships.order(created_at: :desc)
    .includes({ followed: [{ book_tiles: :tile_entries }] }))

    resp = user_following.as_json(include:
      { followed: { only: %i[username id avatar_url], include: { book_tiles: { include: :tile_entries } } } })
    render json: { following: resp, pagy: pagy_metadata(pagy) }
  end

  def nonpaginated
    render json: user.following.select(:id)
  end

  def create
    other_user = User.find(params[:other_user_id])
    user.follow(other_user)
    render json: { message: "You now follow #{other_user.username}" }
  end

  def destroy
    other_user = User.find(params[:id])
    user.unfollow(other_user)
    render json: { message: "You no longer follow #{other_user.username}" }
  end

  private

  def user
    User.find params[:user_id]
  end

  def following_params
    params.permit(:id, :other_user_id)
  end
end
