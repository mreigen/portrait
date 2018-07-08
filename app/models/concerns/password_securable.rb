module PasswordSecurable
  extend ActiveSupport::Concern

  included do
    attr_accessor :password # removed password column, use this as a temp attribute to be encrypted
    before_save   :update_password_if_needed
    validate      :password_presence

    private

    def password_presence
      if self.persisted? # updating
        if self.encrypted_password.blank? || self.password&.empty?
          add_missing_password_error
          return false
        end
      else # new record
        if self.password.blank?
          add_missing_password_error
          return false
        end
      end
      true
    end

    def add_missing_password_error
      self.errors.add(:password, 'cannot be empty')
    end

    def update_password_if_needed
      if self.password.present?
        self.salt, self.encrypted_password = AuthenticationService.encrypt_password(self, self.password)
      end
    end

  end # included do

end