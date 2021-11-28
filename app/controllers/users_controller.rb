class UsersController < ApplicationController
  before_action :users, only: :index
  before_action :user, except: %i[index create]
  before_action :book, only: :add_to_fav_books
  before_action :tile_entry, only: :add_to_fav_tile_entries
  skip_before_action :authenticate_request, only: %i[create]

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

  def fav_books
    render json: user.fav_books.as_json(include: %i[authors category])
  end

  def add_to_fav_books
    user.add_to_fav_books(book)
    if user.fav_books.include?(book)
      render json: { message: 'book added to favorites' }
    else
      render json: { message: 'error' }
    end
  end

  def fav_tile_entries
    render json: user.fav_tile_entries.as_json(include:
      [book_tile:
        { include:
          [{ user: { only: :username } }, :book] }])
  end

  def add_to_fav_tile_entries
    user.add_to_fav_tile_entries(tile_entry)
    if user.fav_tile_entries.include?(tile_entry)
      render json: { message: 'insight added to favorites' }
    else
      render json: { message: 'error' }
    end
  end

  private

  def user
    User.find(params[:id])
  end

  def users
    User.all.map { |user| { id: user.id, email_address: user.email_address } }
  end

  def book
    Book.find(params[:book_id])
  end

  def tile_entry
    TileEntry.find(params[:tile_entry_id])
  end

  def user_params
    params.require(:user).permit(:name, :surname, :username, :email_address, :password, :password_confirmation)
  end

  def follow_params
    params.permit(:other_user_id)
  end
end
