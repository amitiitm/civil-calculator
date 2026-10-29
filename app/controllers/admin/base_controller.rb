class Admin::BaseController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  layout "admin"

  private

  def require_admin!
    return if current_user&.admin?

    flash[:alert] = "Admin access only."
    redirect_to root_path
  end
end
