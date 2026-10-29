class Admin::DashboardController < Admin::BaseController
  def index
    @projects_count = Project.count
    @estimates_count = Estimate.count
    @users_count = User.count
    @materials_count = Material.active.count
    @recent_projects = Project.order(created_at: :desc).limit(10)
  end
end
