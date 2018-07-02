class UsersController < ApplicationController
  include Authenticatable

  before_action :user_required, except: [:reset_password, :update_password, :send_reset_password_email, :change_password]
  before_action :get_user, only: [:show, :update, :destroy]

  def reset_password
  end

  def send_reset_password_email
    if params[:email].blank?
      render json: {message: 'Missing email'}, status: :bad_request and return
    end

    if @user = User.find_by_email(params[:email])
      EmailService.send_password_reset_email(@user)
      render 'users/reset_password_email_sent', locals: {email: @user.email}
    else
      render 'users/user_not_found', status: :not_found
    end
  end

  def change_password
    @reset_password_token = params[:token]
    @user = User.find_by(reset_password_token: @reset_password_token)
  end

  def update_password
    if (params.keys & ['password', 'reset_password_token']).empty?
      render json: {message: 'Not a valid request to update the password'}, status: :bad_request and return
    end

    if @user = User.find_by(reset_password_token: params[:reset_password_token])
      @user.update_attributes! password: params[:password]

      flash[:notice] = "Successfully updated your password, please log in with your new password!"
      redirect_to :root
    else
      render 'users/user_not_found', status: :not_found
    end

  rescue ActiveRecord::RecordInvalid
    flash[:notice] = 'Could not update the password'
    redirect_to :root
  end

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
    update_params = user_params.dup

    # when password is blank but there is at least another field needs to be updated
    # in other words, when password is blank, don't update it
    if should_remove_password_param?(update_params)
      update_params = update_params.except(:password)
    end

    @user.update_attributes! update_params
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
    params.require(:user).permit(:name, :password, :reset_password_token, :email)
  end

  def should_remove_password_param? update_params
    update_params.keys.include?('password') && update_params[:password].empty? && update_params.keys.size > 1
  end

end
