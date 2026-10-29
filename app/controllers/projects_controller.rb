class ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [ :show, :edit, :update, :destroy, :archive, :duplicate ]

  def index
    @projects = policy_scope(Project).order(updated_at: :desc)
  end

  def show
    authorize @project
    @estimates = @project.estimates.order(version_number: :desc)
  end

  def new
    @project = current_user.projects.build
    authorize @project
  end

  def create
    @project = current_user.projects.build(project_params)
    authorize @project

    if @project.save
      Projects::DefaultLayoutService.new(@project).call
      redirect_to @project, notice: "Project created with default floors & rooms based on your BHK selection. Edit anytime in Floors & Rooms."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @project
  end

  def update
    authorize @project

    if @project.update(project_params)
      redirect_to @project, notice: "Project updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @project
    @project.destroy
    redirect_to projects_path, notice: "Project deleted."
  end

  def archive
    authorize @project
    @project.update!(status: :archived)
    redirect_to projects_path, notice: "Project archived."
  end

  def duplicate
    authorize @project
    duplicate = @project.dup
    duplicate.name = "#{@project.name} (Copy)"
    duplicate.status = :draft
    duplicate.save!
    redirect_to duplicate, notice: "Project duplicated."
  end

  private

  def set_project
    @project = Project.find(params[:id])
  end

  def project_params
    params.require(:project).permit(
      :name, :client_name, :city, :state, :plot_length_ft, :plot_width_ft,
      :construction_length_ft, :construction_width_ft, :floors_count,
      :bhk_type, :construction_quality, :status, :notes
    )
  end
end
