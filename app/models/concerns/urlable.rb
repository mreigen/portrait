module Urlable
  extend ActiveSupport::Concern

  def api_url
    if Rails.env.production?
      api_url = ENV['API_URL_PROD']
    elsif Rails.env.development?
      api_url = ENV['API_URL']
    end
    api_url
  end

  def change_password_link user, text, token = nil
    "<a href='#{change_password_url(user, token)}'>#{text}</a>"
  end

  def change_password_url user, token = nil
    token ||= user.reset_password_token
    "#{api_url}/users/#{user.name}/change_password?token=#{token}"
  end

end