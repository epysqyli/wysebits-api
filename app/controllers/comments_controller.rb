class CommentsController < ApplicationController
  skip_before_action :authenticate_request, only: %i[index show]
  before_action :find_commentable, only: %i[index create]
  before_action :comment, only: %i[show]

  def index
    if @commentable.instance_of?(TileEntry)
      render json: { data: @commentable.comments }
    elsif @commentable.instance_of?(Comment)
      render json: { data: @commentable.replies }
    end
  end

  def show
    render json: { data: comment.to_json(include: :to_what) }
  end

  def create
    @comment = Comment.new(comment_params)
    @current_user.comments << @comment

    if params[:tile_entry_id]
      @commentable.comments << @comment
    elsif params[:comment_id]
      @commentable.replies << @comment
    end

    if @comment.save
      render json: { message: 'Comment posted', comment: @comment }
    else
      render json: { message: @comment.errors.messages }
    end
  end

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
