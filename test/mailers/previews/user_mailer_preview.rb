# Preview all emails at http://localhost:3001/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview
  def signup_confirmation
    UserMailer.with(user: User.last).signup_confirmation
  end

  def reset_password
    UserMailer.with(user: User.last).reset_password
  end

  def update_email
    UserMailer.with(user: User.last).update_email
  end
end
