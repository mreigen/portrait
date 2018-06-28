class User < ApplicationRecord
  include Authenticatable

  def self.authenticate(name, password)
    user = User.find_by name: name
    return user if user.present? && Authenticatable.valid_password?(user, password)
    nil
  end

  has_many :sites, dependent: :destroy

  scope :by_name, ->{ order(name: :asc) }

  def to_param() name end

  validates :password, presence: true
  validates :name, uniqueness: true, format: /[a-z0-9]+/
end
