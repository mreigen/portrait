class UsersController < ApplicationController
  include Authenticatable

  before_action :user_required
  before_action :get_user, only: [:show, :update, :destroy]

  # GET /users
  def index
    @users = User.by_name
    @user  = User.new
  end

  # GET /users/:id
  def show
  end

  # POST /user
  def create
    @user = User.new user_params
    @user.save!
    redirect_to users_url
  rescue ActiveRecord::RecordInvalid
    @users = User.by_name
    render :index
  end

  # PUT /users/:id
  def update
    @user.update_attributes! user_params
    redirect_to @user
  rescue ActiveRecord::RecordInvalid
    render :show
  end

  # DELETE /users/:id
  def destroy
    @user.destroy
    redirect_to users_url
  end

  private

  def get_user
    @user = User.find_by! name: params[:id]
  end

  def user_params
    params.require(:user).permit(:name, :password)
  end

end
