class User < ApplicationRecord
  include Authenticatable
  has_many :sites, dependent: :destroy

  scope :by_name, ->{ order(name: :asc) }

  def to_param() name end

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

  scope :by_name, ->{ order(name: :asc) }

  def to_param() name end

  validates :password, presence: true
end
