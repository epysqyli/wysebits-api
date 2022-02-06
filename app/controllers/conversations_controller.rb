class ConversationsController < ApplicationController
  include Pagy::Backend

  before_action :conversation_params, only: :create
  before_action :user, only: :index

  def index
    pagy, conversations = pagy(user.conversations.includes(:messages).order(created_at: :desc))
    resp = conversations.as_json(include: :messages)
    render json: { conversations: resp, pagy: pagy_metadata(pagy) }
  end

  def create
    if Conversation.valid?(conversation_params[:sender_id], conversation_params[:recipient_id])
      Conversation.create! sender_id: conversation_params[:sender_id], recipient_id: conversation_params[:recipient_id]
      render json: { status: 'ok' }, status: :ok
    else
      render json: { status: 'Conversation not created' }, status: :forbidden
    end
  end

  private

  def user
    User.find params[:user_id]
  end

  def conversation_params
    params.permit(:sender_id, :recipient_id)
  end
end
