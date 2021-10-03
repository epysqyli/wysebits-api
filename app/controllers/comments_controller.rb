class CommentsController < ApplicationController
  skip_before_action :authenticate_request, only: %i[index show]

  def index
    if @commentable.instance_of?(TileEntry)
      render json: { data: @commentable.comments }
    elsif @commentable.instance_of?(Comment)
      render json: { data: @commentable.replies }
    end
  end

  def show; end

  def create; end

  def update; end

  def destroy; end

  private

  def find_commentable
    if params[:comment_id]
      @commentable = Comment.find(params[:comment_id])
    elsif params[:tile_entry_id]
      @commentable = TileEntry.find(params[:tile_entry_id])
    end
  end

  def comment
    Comment.find(params[:id])
  end

  def comment_params
    params.permit(:content)
  end
end
