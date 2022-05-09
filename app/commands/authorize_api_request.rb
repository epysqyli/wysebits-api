class AuthorizeApiRequest
  prepend SimpleCommand

  def initialize(cookies = {})
    @cookies = cookies
  end

  def call
    user
  end

  private

  attr_reader :headers

  def user
    @user ||= User.find(decoded_auth_token[:user_id]) if decoded_auth_token
    @user || errors.add(:token, 'Invalid token') && nil
  end

  def decoded_auth_token
    @decoded_auth_token ||= JsonWebToken.decode(http_auth_cookie)
  end

  def http_auth_cookie
    return @cookies['jwt'] if @cookies['jwt'].present?

    errors.add(:token, 'Missing token')
    nil
  end
end
