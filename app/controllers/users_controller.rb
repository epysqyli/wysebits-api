class UsersController < ApplicationController
  include Pagy::Backend

  before_action :users, only: :index
  before_action :user, except: %i[index create]
  before_action :book, only: %i[add_to_fav_books remove_from_fav_books]
  before_action :tile_entry,
                only: %i[add_to_fav_tile_entries remove_from_fav_tile_entries upvote downvote remove_upvote
                         remove_downvote]
  skip_before_action :authenticate_request, only: %i[create]

  # model CRUD
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

  # user relationships
  def following
    render json: user.following.as_json({ only: %i[username id] })
  end

  def followers
    render json: user.followers.as_json({ only: %i[username id] })
  end

  def add_following
    user_to_follow = User.find(follow_params[:other_user_id])
    user.follow(user_to_follow)
    render json: { message: "You now follow #{user_to_follow.username}" }
  end

  def remove_following
    user_to_unfollow = User.find(follow_params[:other_user_id])
    user.unfollow(user_to_unfollow)
    render json: { message: "You no longer follow #{user_to_unfollow.username}" }
  end

  # fav books actions
  def fav_books
    pagy, liked_books = pagy(user.fav_books.order(created_at: :desc))
    resp = liked_books.as_json(include: { book: { include: %i[authors category] } })
    render json: { books: resp, pagy: pagy_metadata(pagy) }
  end

  def add_to_fav_books
    user.add_to_fav_books(book)
    metric_data = book.find_or_create_metric_data
    metric_data.fav_books_count += 1
    metric_data.save
    if user.liked_books.include?(book)
      render json: { message: 'book added to favorites', book: book, fav_books: user.fav_books }
    else
      render json: { message: 'error' }
    end
  end

  def remove_from_fav_books
    user.remove_from_fav_books(book)
    metric_data = book.find_or_create_metric_data
    metric_data.fav_books_count -= 1
    metric_data.save
    render json: { message: "#{book.title} removed from favorite books", fav_books: user.fav_books }
  end

  # fav insights actions
  def fav_tile_entries
    pagy, fav_tile_entries = pagy(user.fav_tile_entries.order(created_at: :desc))
    resp = fav_tile_entries.as_json(include: [tile_entry: { include:
      [book_tile:
        { include:
          [{ user: { only: :username } }, :book] }] }]).map { |item| item['tile_entry'] }
    render json: { tile_entries: resp, pagy: pagy_metadata(pagy) }
  end

  def add_to_fav_tile_entries
    user.add_to_fav_tile_entries(tile_entry)
    book = tile_entry.book_tile.book
    metric_data = book.find_or_create_metric_data
    metric_data.fav_entries_count += 1
    metric_data.save
    if user.fav_tile_entries.include?(tile_entry)
      render json: { message: 'insight added to favorites' }
    else
      render json: { message: 'error' }
    end
  end

  def remove_from_fav_tile_entries
    user.remove_from_fav_tile_entries(tile_entry)
    book = tile_entry.book_tile.book
    metric_data = book.find_or_create_metric_data
    metric_data.fav_entries_count -= 1
    metric_data.save
    if user.fav_tile_entries.include?(tile_entry)
      render json: { message: 'error' }
    else
      render json: { message: 'insight removed from favorites' }
    end
  end

  # upvote/downvote actions
  def upvoted_entries
    render json: { upvoted_entries: user.upvoted_entries }
  end

  def downvoted_entries
    render json: { downvoted_entries: user.downvoted_entries }
  end

  def upvote
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

  def remove_upvote
    user.remove_upvote(tile_entry)
    book = tile_entry.book_tile.book
    metric_data = book.find_or_create_metric_data
    metric_data.upvotes_count -= 1
    metric_data.save
    render json: { message: 'Upvote removed' }
  end

  def downvote
    if user.downvoted_entries.include?(tile_entry)
      render json: { message: 'Entry already downvoted' }
    else
      user.downvote(tile_entry)
      book = tile_entry.book_tile.book
      metric_data = book.find_or_create_metric_data
      metric_data.downvotes_count += 1
      metric_data.save
      render json: { message: 'Downvote submitted' }
    end
  end

  def remove_downvote
    user.remove_downvote(tile_entry)
    book = tile_entry.book_tile.book
    metric_data = book.find_or_create_metric_data
    metric_data.downvotes_count -= 1
    metric_data.save
    render json: { message: 'Downvote removed' }
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
