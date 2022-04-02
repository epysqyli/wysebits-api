class CommentsController < ApplicationController
  before_action :find_commentable, only: %i[index create]
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
    new_comment = Comment.new(comment_params.fetch(:comment))

    if params[:tile_entry_id]
      @commentable.comments << new_comment
      render json: CommentFormat.username_only(new_comment)
    elsif params[:comment_id]
      @commentable.replies << new_comment
      render json: CommentFormat.username_only(new_comment)
    else
      render json: new_comment.errors.messages
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
    params.permit(:content, :commentable_id, :commentable_type, :user_id, :tile_entry_id,
                  comment: %i[commentable_id commentable_type content user_id])
  end
end
