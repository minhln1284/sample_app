class PasswordResetsController < ApplicationController
  before_action :find_user, :valid_user, :check_expiration,
                only: %i(edit update)
  before_action :find_resetter, only: :create
  def new; end

  def create
    @user.create_reset_digest
    @user.send_password_reset_email
    flash[:info] = t ".email_sent"
    redirect_to root_path
  end

  def edit; end

  def update
    if params[:user][:password].blank?
      @user.errors.add :password, t(".cant_empty")
      render :edit
    elsif @user.update(user_params)
      log_in @user
      flash[:success] = t ".has_reset"
      redirect_to @user
    else
      flash[:danger] = t ".reset_failed"
      render :edit
    end
  end

  def check_expiration
    return unless @user.password_reset_expired?

    flash[:danger] = t ".has_expired"
    redirect_to new_password_reset_path
  end

  private
  def find_user
    @user = User.find_by email: params[:email]
    return if @user

    flash[:danger] = t ".create.email_not_found"
    redirect_to login_path
  end

  def find_resetter
    @user = User.find_by(email: params[:password_reset][:email].downcase)
    return if @user

    flash.now[:danger] = t ".email_not_found"
    render :new
  end

  def valid_user
    unless @user&.activated? && @user&.authenticated?(:reset,
                                                      params[:id])

      redirect_to root_path
    end
  end

  def user_params
    params.require(:user).permit :password, :password_confirmation
  end
end
