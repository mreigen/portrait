class User < ApplicationRecord
  attr_accessor :password # removed password column, use this as a temp attribute to be encrypted

  has_many :sites, dependent: :destroy

  scope :by_name, ->{ order(name: :asc) }

  def to_param() name end

  validate  :password_presence
  validates :name, uniqueness: true, format: /[a-z0-9]+/

  after_create :encrypt_password

  def self.authenticate(name, password)
    user = User.find_by name: name
    return user if user.present? && AuthenticationService.valid_password?(user, password)
    nil
  end

  def encrypt_password
    if self.encrypted_password.blank? && self.salt.blank?
      salt, password = AuthenticationService.encrypt_password(self, self.password)
      self.update(encrypted_password: password, salt: salt)
    end
  end

  private

  def password_presence
    if self.persisted?
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

end
