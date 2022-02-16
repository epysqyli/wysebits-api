class MessagesController < ApplicationController
  before_action :message_params, only: :create
  before_action :conversation

  def index
    messages = conversation.messages.includes(:user).order(created_at: :asc)
    render json: { messages: messages.as_json(include: { user: { only: %i[username id] } }) }
  end

  def create
    msg = user.send_message(conversation, message_params[:content])
    if msg
      render json: { status: 'ok', message: msg.as_json(include: { user: { only: %i[username id] } }) }, status: :ok
    else
      render json: { status: 'Message not sent' }, status: :forbidden
    end
  end

  private

  def user
    User.find message_params[:user_id]
  end

  def conversation
    Conversation.find params[:conversation_id]
  end

  def message_params
    params.permit(:content, :user_id, :conversation_id, message: %i[content user_id])
  end
end
