class ConversationsController < ApplicationController
  include Pagy::Backend

  before_action :conversation_params, only: %i[show create]
  before_action :user, only: :index

  def index
    pagy, conversations = pagy(user.conversations.includes(:messages).order(created_at: :desc))
    conversations.map { |conv| conv.append_partner user }
    resp = conversations.as_json(include: %i[partner last_message], methods: :messages_count)
    render json: { conversations: resp, pagy: pagy_metadata(pagy) }
  end

  def show
    conversation = Conversation.between(conversation_params[:sender_id], conversation_params[:recipient_id]).first
    conversation.append_partner(User.find(conversation_params[:sender_id]))
    render json: conversation.as_json(include: :partner)
  end

  def create
    if Conversation.valid?(conversation_params[:sender_id], conversation_params[:recipient_id])
      Conversation.create! sender_id: conversation_params[:sender_id], recipient_id: conversation_params[:recipient_id]
      render json: { status: 'ok' }, status: :ok
    else
      show
    end
  end

  private

  def user
    User.find params[:user_id]
  end

  def conversation_params
    params.permit(:sender_id, :recipient_id, :user_id, conversation: %i[sender_id recipient_id])
  end
end
