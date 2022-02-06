class ConversationsController < ApplicationController
  before_action :conversation_params, only: :create

  def index; end

  def create; end

  private

  def conversation_params
    params.permit(:sender_id, :recipient_id)
  end
end
