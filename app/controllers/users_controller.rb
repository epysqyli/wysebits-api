class UsersController < ApplicationController
  include Pagy::Backend

  before_action :users, only: :index
  before_action :user, except: %i[index create]
  before_action :book, only: %i[add_to_fav_books remove_from_fav_books]
  before_action :tile_entry,
                only: %i[add_to_fav_tile_entries remove_from_fav_tile_entries upvote downvote remove_upvote
                         remove_downvote]
  before_action :category, only: %i[add_to_fav_categories remove_from_fav_categories]
  before_action :user_params, only: %i[create update_avatar]
  before_action :validate_new_email_address, only: :update_email
  skip_before_action :authenticate_request,
                     only: %i[show create confirm_account confirm_email_update username_available?
                              email_address_available?]

  def index
    render json: { users: users }
  end

  def show
    if user
      book_tiles = user.book_tiles.order(created_at: :desc)
                       .includes(
                         { tile_entries: [{ book_tile: %i[book user] }] },
                         { book: %i[authors category] }
                       )

      book_tiles_resp = book_tiles.as_json(include: [{ tile_entries:
        { include: { book_tile: { include: [:book, { user: { only: %i[id username] } }] } } } },
                                                     { book: { include: %i[authors category] } }])

      user_followers = user.followers.as_json(only: %i[username id])
      render json: { user: { username: user.username, id: user.id, avatar_url: user.avatar_url },
                     book_tiles: book_tiles_resp, followers: user_followers }
    else
      render json: { message: 'User not found' }, status: 404
    end
  end

  def create
    @user = User.new

    @user.username = user_params[:username]
    @user.email_address = user_params[:email_address]
    @user.password = user_params[:password]

    UserMailer.with(user: @user).signup_confirmation.deliver_now if @user.save

    if user_params[:avatar]
      @user.handle_attachment(user_params[:avatar])
      @user.avatar_url = url_for(@user.avatar)
      @user.save
    end

    if @user.present?
      render json: { status: 'Confirmation email sent' }, status: :ok
    else
      render json: { status: 'Error' }, status: :not_found
    end
  end

  def confirm_account
    token = confirmation_params[:token].to_s
    user = User.find_by_confirmation_token token

    if user.present? && user.confirmation_token_valid?
      user.mark_as_confirmed!
      render json: { status: 'User confirmed successfully' }, status: :ok
    else
      render json: { status: 'Invalid token' }, status: :not_found
    end
  end

  def update_username
    return render json: { status: 'ok' }, status: :ok if current_user.update(user_params)

    render json: { error: user.errors.full_messages }, status: :unprocessable_entity
  end

  def update_email
    if current_user.start_email_update!(@new_email)
      UserMailer.with(user: current_user).update_email.deliver_now
      render json: { status: 'Email Confirmation has been sent to your new Email.' }, status: :ok
    else
      render json: { errors: current_user.errors.values.flatten.compact }, status: :bad_request
    end
  end

  def confirm_email_update
    token = confirmation_params[:token].to_s
    user = User.find_by_confirmation_token token

    if user.nil? || user.confirmation_token_valid? == false
      render json: { error: 'The email link seems to be invalid / expired. Try requesting for a new one.' },
             status: :not_found
    else
      user.update_new_email!
      render json: { status: 'Email updated successfully' }, status: :ok
    end
  end

  def update_avatar
    user.handle_attachment(user_params[:avatar])
    user.update(avatar_url: url_for(user.avatar))

    render json: { avatar_url: user.avatar_url }
  end

  def delete_avatar
    user.avatar.purge
    new_avatar_url = nil
    user.update(avatar_url: new_avatar_url)

    render json: { avatar_url: user.avatar_url }
  end

  def destroy
    if user == current_user
      user.destroy
      render json: { message: 'User destroyed' }
    else
      render json: { message: 'Unauthorized' }, status: 401
    end
  end

  # fav books actions
  def fav_books
    pagy, liked_books = pagy(user.fav_books.order(created_at: :desc).includes(book: %i[authors category]))
    resp = liked_books.as_json(include: { book: { include: %i[authors category] } })
    render json: { books: resp, pagy: pagy_metadata(pagy) }
  end

  def unpaged_fav_books
    render json: user.fav_books.select(:book_id)
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
    pagy, fav_tile_entries = pagy(user.fav_tile_entries.order(created_at: :desc)
    .includes({ tile_entry: [{ book_tile: %i[user book] }] }))

    resp = fav_tile_entries.as_json(include: [tile_entry: { include:
      [book_tile:
        { include:
          [{ user: { only: %i[username id] } }, :book] }] }]).map { |item| item['tile_entry'] }
    render json: { tile_entries: resp, pagy: pagy_metadata(pagy) }
  end

  def unpaged_fav_tile_entries
    entries = user.fav_tile_entries.select(user.fav_tile_entries.arel_table['tile_entry_id'].as('id'))
    render json: { tile_entries: entries }
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
    render json: { upvoted_entries: user.upvoted_entries.select(:id) }
  end

  def downvoted_entries
    render json: { downvoted_entries: user.downvoted_entries.select(:id) }
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

  # user fields availability checks
  def username_available?
    return render json: true if User.username_available? user_params[:username]

    render json: false
  end

  def email_address_available?
    return render json: true if User.email_address_available? user_params[:email_address]

    render json: false
  end

  private

  def user
    params[:id] ? User.find(params[:id]) : User.find_by_username(params[:username])
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

  def category
    Category.find(params[:category_id])
  end

  def validate_new_email_address
    @new_email = user_params[:email_address].to_s.downcase

    return render json: { status: 'Email cannot be blank' }, status: :bad_request if @new_email.blank?

    if @new_email == current_user.email_address
      return render json: { status: 'Current Email and New email cannot be the same' },
                    status: :bad_request
    end

    render json: { error: 'Email is already in use.' }, status: :unprocessable_entity if User.email_used?(@new_email)
  end

  def confirmation_params
    params.permit(:token)
  end

  def user_params
    params.require(:user).permit(:username, :email_address, :password, :avatar)
  end
end
