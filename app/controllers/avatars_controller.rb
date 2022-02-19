class AvatarsController < ApplicationController
  before_action :user
  skip_before_action :authenticate_request, only: :show

  def show
    render json: user.avatar_url
  end

  def create
    user.handle_attachment(user_params[:avatar])
    user.update(avatar_url: url_for(user.avatar))

    render json: { avatar_url: user.avatar_url }
  end

  def destroy
    user.avatar.purge
    user.update(avatar_url: nil)

    render json: { avatar_url: user.avatar_url }
  end

  private

  def user
    User.find params[:user_id]
  end

  def user_params
    params.require(:user).permit(:avatar)
  end
end
