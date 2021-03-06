class UsersController < ApplicationController
  before_action :logged_in_user, except: [:show, :create, :new]
  before_action :find_user, except: [:index, :new, :create]
  before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy]

  def index
    @users = User.activated?.paginate(page: params[:page],
      per_page: Settings.controller.per_page)
  end

  def show
    @microposts = @user.microposts.paginate(page: params[:page])
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new param_users
    if @user.save
      @user.send_activation_email
      flash[:info] = t "users.new.please_check_mail"
      redirect_to root_path
    else
      render :new
    end
  end

  def edit; end

  def update
    if @user.update_attributes param_users
      flash[:success] = t "users.edit.update_success"
      redirect_to @user
    else
      render :edit
    end
  end

  def destroy
    if @user.destroy
      flash[:success] = t "users.index.delete_success"
      redirect_to users_url
    else
      flash[:danger] = t "shared.error_messages.notfound"
      redirect_to notfound_path
    end
  end

  def following
    @title = t "shared.stats.following"
    @users = @user.following.paginate(page: params[:page])
    render :show_follow
  end

  def followers
    @title =  t "shared.stats.followers"
    @users = @user.followers.paginate(page: params[:page])
    render :show_follow
  end

  private

  def param_users
    params.require(:user).permit(:name, :email,
      :password, :password_confirmation)
  end

  def correct_user
    redirect_to root_path unless current_user? @user
  end

  def admin_user
    redirect_to root_path unless current_user.admin?
  end

  def find_user
    @user = User.find_by(id: params[:id])
    return if @user
    flash[:danger] = t "shared.error_messages.notfound"
    redirect_to notfound_path
  end
end
