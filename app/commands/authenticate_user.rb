class AuthenticateUser
  prepend SimpleCommand

  def initialize(email_address, password)
    @email_address = email_address
    @password = password
  end

  def call
    return unless user

    { token: JsonWebToken.encode(user_id: user.id),
      user: { username: user.username, email_address: user.email_address } }
  end

  private

  attr_accessor :email_address, :password

  def user
    user = User.find_by_email_address(email_address)
    return user if user&.authenticate(password) && user&.confirmation_token.nil?

    errors.add :user_authentication, 'invalid credentials'
    nil
  end
end
