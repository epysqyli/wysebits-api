class ConversationsController < ApplicationController
  before_action :conversation_params, only: :create

  def index; end

  def create
    if Conversation.valid?(conversation_params[:sender_id], conversation_params[:recipient_id])
      Conversation.create! sender_id: conversation_params[:sender_id], recipient_id: conversation_params[:recipient_id]
      render json: { status: 'ok' }, status: :ok
    else
      render json: { status: 'Conversation not created' }, status: :forbidden
    end
  end

  private

  def conversation_params
    params.permit(:sender_id, :recipient_id)
  end
end
