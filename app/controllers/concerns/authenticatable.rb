module Authenticatable
  extend ActiveSupport::Concern

  protected

  def user_required
    authenticate_or_request_with_http_basic do |username, password|
      @current_user = User.authenticate username, password
      @current_user.present?
    end
  end

end