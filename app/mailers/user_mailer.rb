class UserMailer < ApplicationMailer
  default from: 'wysebits@gmail.com'

  def signup_confirmation
    content_type 'text/html'
    @user = params[:user]
    mail(to: @user.email_address, subject: 'Activate your wysebits account')
  end

  def reset_password
    content_type 'text/html'
    @user = params[:user]
    mail(to: @user.email_address, subject: 'Reset password for your Wysebits account')
  end

  def update_email
    content_type 'text/html'
    @user = params[:user]
    mail(to: @user.unconfirmed_email, subject: 'Change your email address for Wysebits')
  end
end
