class AuthenticateUser
  prepend SimpleCommand

  def initialize(email_address, password)
    @email_address = email_address
    @password = password
  end

  def call
    JsonWebToken.encode(user_id: user.id) if user
  end

  private

  attr_accessor :email_address, :password

  def user
    user = User.find_by_email_address(email_address)
    return user if user&.authenticate(password)

    errors.add :user_authentication, 'invalid credentials'
    nil
  end
end
