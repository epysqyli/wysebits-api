class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request, only: :authenticate

  def authenticate
    command = AuthenticateUser.call(params[:email_address], params[:password])
    return render json: { error: command.errors }, status: :unauthorized unless command.success?

    response.set_cookie(
      :jwt, {
        value: command.result[:token],
        expires: 7.days.from_now,
        path: '/',
        domain: ENV['cookie_domain'],
        httponly: true
      }
    )
    render json: { user: command.result[:user] }
  end

  def logged_in
    return unless current_user

    render json: { logged_in: true,
                   user: {
                     username: current_user.username,
                     email: current_user.email_address,
                     id: current_user.id,
                     avatar: current_user.avatar_url
                   } }
  end

  def logout
    return unless current_user

    response.set_cookie(
      :jwt, {
        value: nil,
        expires: Time.now,
        path: '/',
        domain: ENV['cookie_domain'],
        httponly: true
      }
    )

    render json: {
      logged_in: false,
      message: 'User logged out',
      status: 'success'
    }
  end
end
