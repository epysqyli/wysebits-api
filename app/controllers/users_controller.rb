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
      render json: { message: 'User succesfully created', user: { name: @user.name, email: @user.email_address } }
    else
      render json: { error: 'User not created' }, status: 403
    end
  end

  def update; end

  # users should only be able to destroy themselves
  def destroy
    if user == current_user
      user.destroy
      render json: { message: 'User destroyed' }
    else
      render json: { message: 'Unauthorized' }, status: 401
    end
  end

  private

  def user
    User.find(params[:id])
  end

  def users
    User.all.map { |user| { id: user.id, email_address: user.email_address } }
  end

  def user_params
    params.require(:user).permit(:name, :surname, :email_address, :password, :password_confirmation)
  end
end
