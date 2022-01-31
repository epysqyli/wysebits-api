class UserMailer < ApplicationMailer
  default from: 'wysebits@gmail.com'

  def signup_confirmation
    @user = params[:user]
    mail(to: @user.email_address, subject: 'Activate your wysebits account')
  end

  def reset_password
    @user = params[:user]
    mail(to: @user.email_address, subject: 'Reset password for your Wysebits account')
  end
end
