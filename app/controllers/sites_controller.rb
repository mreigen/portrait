class SitesController < ApplicationController
  include Authenticatable

  before_action :user_required

  def index
    @sites = Site.order(created_at: :desc).page params[:page]
    @site  = Site.new
  end

  def create
    @site = @current_user.sites.build site_params
    @site.save
    respond_to do |format|
      format.html { redirect_to sites_url }
      format.json
    end
  end

  private

  def site_params
    params.fetch(:site, {}).permit(:url, :callback_url)
  end

end
