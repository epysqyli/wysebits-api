class FavBooksController < ApplicationController
  include Pagy::Backend

  before_action :user
  before_action :book, only: %i[[create destroy]]

  def index
    pagy, liked_books = pagy(user.fav_books.order(created_at: :desc).includes(book: %i[authors category]))
    resp = liked_books.as_json(include: { book: { include: %i[authors category] } })
    render json: { books: resp, pagy: pagy_metadata(pagy) }
  end

  def nonpaginated
    render json: user.fav_books.select(:book_id)
  end

  def create
    user.add_to_fav_books(book)
    book.find_or_create_metric_data.update_book_metrics('fav_books', :increase)
    if user.liked_books.include?(book)
      render json: { message: 'book added to favorites', book: book, fav_books: user.fav_books }
    else
      render json: { message: 'error' }
    end
  end

  def destroy
    user.remove_from_fav_books(book)
    book.find_or_create_metric_data.update_book_metrics('fav_books', :decrease)
    render json: { message: "#{book.title} removed from favorite books", fav_books: user.fav_books }
  end

  private

  def user
    User.find params[:user_id]
  end

  def book
    Book.find fav_book_params[:id]
  end

  def fav_book_params
    params.permit(:id, :user_id, fav_book: %i[id user_id])
  end
end
