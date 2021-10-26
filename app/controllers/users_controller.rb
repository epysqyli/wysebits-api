class UsersController < ApplicationController
  before_action :users, only: :index
  before_action :user, only: %i[show destroy]
  skip_before_action :authenticate_request, only: :create

  def index
    render json: { users: users }
  end

  def show
    if user
      render json: { user: { user_id: user.id, email_address: user.email_address } }
    else
      render json: { message: 'User not found' }, status: 404
    end
  end

  def create
    @user = User.create!(user_params)
    if @user
      render json: { message: 'User succesfully created', status: 'success',
                     user: { username: @user.username, email: @user.email_address } }
    else
      render json: { error: 'User not created' }, status: 403
    end
  end

  def update; end

  # users should only be able to destroy themselves and their own resources
  def destroy
    if user == current_user
      user.destroy
      render json: { message: 'User destroyed' }
    else
      render json: { message: 'Unauthorized' }, status: 401
    end
  end

  def add_following
    user_to_follow = User.find(follow_params[:other_user_id])
    @current_user.follow(user_to_follow)
    render json: { message: "You now follow #{user_to_follow.name}", current_user: @current_user.name }
  end

  def remove_following
    user_to_unfollow = User.find(follow_params[:other_user_id])
    @current_user.unfollow(user_to_unfollow)
    render json: { message: "You no longer follow #{user_to_unfollow.name}", current_user: @current_user.name }
  end

  private

  def user
    User.find(params[:id])
  end

  def users
    User.all.map { |user| { id: user.id, email_address: user.email_address } }
  end

  def user_params
    params.require(:user).permit(:name, :surname, :username, :email_address, :password, :password_confirmation)
  end

  def follow_params
    params.permit(:other_user_id)
  end
end
