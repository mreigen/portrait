class AuthenticationService
  class << self
    def generate_salt
      SecureRandom.base64(8) # 8 bytes salt
    end

    def encrypt_password(user, password)
      salt = user&.salt.present? ? user.salt : generate_salt
      [salt, Digest::SHA2.hexdigest("#{salt}#{password}")]
    end

    def valid_password?(user, password)
      user.encrypted_password == encrypt_password(user, password)[1]
    end
  end
end