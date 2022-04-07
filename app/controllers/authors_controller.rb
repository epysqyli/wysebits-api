class AuthorsController < ApplicationController
  include Pagy::Backend

  before_action :author, only: :show
  skip_before_action :authenticate_request, only: :show

  def show
    pagy, author_books = pagy(author.books.left_joins(:book_tiles).group(:id).order('COUNT(book_tiles.id) DESC'))
    resp = AuthorFormat.authors_category(author_books.includes(:authors, :category))
    render json: { books: resp, pagy: pagy_metadata(pagy) }
  end

  def create
    new_author = Author.new full_name: author_params[:full_name]
    if new_author.save
      render json: new_author
    else
      render json: new_author.errors.messages
    end
  end

  private

  def author
    Author.find(params[:id])
  end

  def author_params
    params.permit(:full_name)
  end
end
