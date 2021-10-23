class AuthenticationController < ApplicationController
  skip_before_action :authenticate_request

  def authenticate
    command = AuthenticateUser.call(params[:email_address], params[:password])

    if command.success?
      response.set_cookie(
        :jwt, {
          value: command.result,
          expires: 7.days.from_now,
          path: '/',
          httponly: true
        }
      )

      render json: { auth_token: command.result }
    else
      render json: { error: command.errors }, status: :unauthorized
    end
  end
end
