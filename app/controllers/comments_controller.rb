class CommentsController < ApplicationController
  before_action :find_commentable, only: :index
  before_action :comment, only: %i[show]
  skip_before_action :authenticate_request, except: :create

  def index
    if @commentable.instance_of?(TileEntry)
      render json: CommentFormat.username_only(@commentable.comments.order(created_at: :desc))
    elsif @commentable.instance_of?(Comment)
      render json: @commentable.replies
    end
  end

  def show
    render json: { data: comment.to_json(include: :to_what) }
  end

  def create
    comment = Comment.new(comment_params)

    if params[:tile_entry_id]
      @commentable.comments << comment
    elsif params[:comment_id]
      @commentable.replies << comment
    end

    if comment.save
      render json: CommentFormat.username_only(comment)
    else
      render json: @comment.errors.messages
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
    params.permit(:content, :commentable_id, :commentable_type)
  end
end
