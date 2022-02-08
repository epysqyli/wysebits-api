class FavCategoriesController < ApplicationController
  before_action :user
  before_action :category, except: :index

  def index
    render json: user.fav_categories
  end

  def create
    user.add_to_fav_categories category
    render json: user.fav_categories
  end

  def destroy
    user.remove_from_fav_categories category
    render json: user.fav_categories
  end

  private

  def user
    User.find params[:user_id]
  end

  def category
    Category.find categories_params[:id]
  end

  def categories_params
    params.permit(:id, :user_id, fav_category: %i[id user_id])
  end
end
