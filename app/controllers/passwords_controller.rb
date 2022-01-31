class PasswordsController < ApplicationController
  def forgot
    return render json: { error: 'Email address not present' } if params[:email_address].blank?

    user = User.find_by_email_address user_params[:email_address]
    if user.present? && user.confirmed_at?
      user.generate_password_token!
      UserMailer.with(user: @user).reset_password.deliver_now
      render json: { status: 'ok' }, status: :ok
    else
      render json: { error: 'Email address not found' }, status: :not_found
    end
  end

  def reset
    return render json: { error: 'Token not present' } if confirmation_params[:token].blank?

    token = reset_params[:token].to_s
    user = User.find_by_reset_password_token token

    if user.present? && user.password_token_valid?
      if user.reset_password! reset_params[:password]
        render json: { status: 'ok' }, status: :ok
      else
        render json: { error: user.errors.full_messages }, status: :unprocessable_entity
      end
    else
      render json: { error: ['Link not valid or expired'] }, status: :not_found
    end
  end

  private

  def user_params
    params.permit(:email_address)
  end

  def reset_params
    params.permit(:token, :password)
  end
end
