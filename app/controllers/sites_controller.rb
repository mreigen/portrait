class SitesController < ApplicationController
  before_filter      :user_required,  :only=>:api
  skip_before_filter :admin_required, :only=>:api

  # GET /sites
  def index
    @sites = Site.paginate :page=>params[:page]
    @site  = Site.new
  end
  
  # POST /sites
  def create
    @site = @user.sites.build params[:site]
    @site.save!
    redirect_to sites_path
  rescue ActiveRecord::RecordInvalid
    @sites = Site.paginate :page=>params[:page]
    render :action=>:index
  end
  
  # POST /
  def api
    @site = @user.sites.build :url=>params[:url]
    @site.save!
    render :xml=>@site.to_xml
  rescue ActiveRecord::RecordInvalid
    render :text=>@site.errors.to_xml, :status=>500
  end

end
