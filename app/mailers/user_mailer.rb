class UserMailer < ApplicationMailer
  default from: 'wysebits@gmail.com'

  def signup_confirmation
    @user = params[:user]
    @base_url = ENV['base_url']
    attachments.inline['logo'] = File.read(Rails.root.join('public/gimp-logo-black.png'))
    mail(to: @user.email_address, subject: 'Activate your wysebits account')
  end

  def reset_password
    @user = params[:user]
    @base_url = ENV['base_url']
    attachments.inline['logo'] = File.read(Rails.root.join('public/gimp-logo-black.png'))
    mail(to: @user.email_address, subject: 'Reset password for your Wysebits account')
  end

  def update_email
    @user = params[:user]
    @base_url = ENV['base_url']
    attachments.inline['logo'] = File.read(Rails.root.join('public/gimp-logo-black.png'))
    mail(to: @user.unconfirmed_email, subject: 'Change your email address for Wysebits')
  end
end
