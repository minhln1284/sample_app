class UsersController < ApplicationController
  before_action :logged_in_user, only: %i(index edit update destroy)

  before_action :find_user, except: %i(index new create)

  before_action :correct_user, only: %i(edit update)

  def index
    @pagy, @users = pagy User.latest_users, page: params[:page],
                                            items: Settings.user.items
  end

  def new
    @user = User.new
  end

  def show; end

  def create
    @user = User.new user_params
    if @user.save
      flash[:success] = t ".alert_success"
      redirect_to root_path
    else
      flash[:danger] = t ".alert_success"
      render :new
    end
  end

  def edit; end

  def update
    if @user.update user_params
      flash[:success] = t ".profile_updated"
      redirect_to @user
    else
      flash[:danger] = t ".profile_update_failed"
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t ".user_deleted"
    else
      flash[:danger] = t ".delete_failed"
    end
    redirect_to users_url
  end

  private

  def find_user
    @user = User.find_by id: params[:id]
    return if @user

    flash[:danger] = t ".alert_not_found"
    redirect_to signup_path
  end

  def user_params
    params.require(:user).permit(User::USER_ATTR)
  end

  def logged_in_user
    return if logged_in?

    store_location
    flash[:danger] = t ".log_in"
    redirect_to login_url
  end

  def correct_user
    return if current_user? @user

    flash[:danger] = t ".not_found"
    redirect_to root_url
  end
end
