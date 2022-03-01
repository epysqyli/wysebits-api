class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request, only: :authenticate

  def authenticate
    command = AuthenticateUser.call(params[:email_address], params[:password])

    if command.success?
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
    else
      render json: { error: command.errors }, status: :unauthorized
    end
  end

  def logged_in
    if current_user
      render json: { logged_in: true,
                     user: { username: current_user.username, email: current_user.email_address, id: current_user.id,
                             avatar: current_user.avatar_url } }
    else
      render json: { message: 'No user is logged in' }
    end
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

    render json: { message: 'User logged out', status: 'success' }
  end
end
