class MessagesController < ApplicationController
  before_action :message_params, only: :create

  def index; end

  def create; end

  private

  def user
    User.find params[:user_id]
  end

  def message_params
    params.permit(:conversation_id, :content)
  end
end
