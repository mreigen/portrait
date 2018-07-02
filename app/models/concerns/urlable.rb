module Urlable
  extend ActiveSupport::Concern

  def change_password_link user, text, token = nil
    "<a href='#{change_password_url(user, token)}'>#{text}</a>"
  end

  def change_password_url user, token = nil
    token ||= user.reset_password_token
    "#{ENV['BASE_URL']}/users/#{user.name}/change_password?token=#{token}"
  end

end