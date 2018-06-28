module Authenticatable
  extend ActiveSupport::Concern

  class << self
    def generate_salt
      SecureRandom.base64(8) # 8 bytes salt
    end

    def encrypt_password(user, password)
      salt = user.salt.present? ? user.salt : generate_salt
      [salt, Digest::SHA2.hexdigest("#{salt}#{password}")]
    end

    def valid_password?(user, password)
      user.encrypted_password == encrypt_password(user, password)[1]
    end
  end

  protected

  def user_required
    authenticate_or_request_with_http_basic do |username, password|
      @current_user = User.authenticate username, password
      @current_user.present?
    end
  end

end