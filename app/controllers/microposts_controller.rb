class MicropostsController < ApplicationController
  before_action :logged_in_user, only: %i(create destroy)
  before_action :correct_user, only: :destroy

  def create
    @micropost = current_user.microposts.build(micropost_params)
    @micropost.image.attach params[:micropost][:image]
    if @micropost.save
      flash[:success] = t ".created"
      redirect_to root_path
    else
      @pagy, @feed_items = pagy current_user.feed
      render "static_pages/home"
    end
  end

  def destroy
    if @micropost.destroy
      flash[:success] = t ".deleted"
    else
      flash[:danger] = t ".delete_failed"
      redirect_to request.referer || root_path
    end
  end

  private

  def micropost_params
    params.require(:micropost).permit(:content, :image)
  end
end
