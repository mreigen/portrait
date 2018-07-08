class User < ApplicationRecord
  include PasswordSecurable

  has_many :sites, dependent: :destroy

  scope :by_name, ->{ order(name: :asc) }

  def to_param() name end

  validates :name, uniqueness: true, format: /[a-z0-9]+/
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }

  def self.authenticate(name, password)
    user = User.find_by name: name
    return user if user.present? && AuthenticationService.valid_password?(user, password)
    nil
  end

  def invalidate_reset_token
    self.update_attributes! reset_password_token: nil
  end

end
