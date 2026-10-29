class Admin::UsersController < Admin::BaseController
  before_action :set_user, only: [ :edit, :update ]

  def index
    @users = User.order(created_at: :desc)
  end

  def edit; end

  # Role changes are restricted to this admin-only action - never mass-assignable
  # from the public registration form.
  def update
    if @user.update(role: user_params[:role])
      redirect_to admin_users_path, notice: "User role updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_user
    @user = User.find(params[:id])
  end

  def user_params
    params.require(:user).permit(:role)
  end
end
