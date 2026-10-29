class ProjectFloorsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project, only: [ :new, :create ]
  before_action :set_project_floor, only: [ :edit, :update, :destroy ]

  def new
    @project_floor = @project.project_floors.build(
      floor_number: @project.project_floors.maximum(:floor_number).to_i + 1, bhk_type: @project.bhk_type
    )
    authorize @project_floor
  end

  def create
    @project_floor = @project.project_floors.build(project_floor_params)
    authorize @project_floor

    if @project_floor.save
      redirect_to @project, notice: "Floor added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @project_floor
  end

  def update
    authorize @project_floor

    if @project_floor.update(project_floor_params)
      redirect_to @project_floor.project, notice: "Floor updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @project_floor
    project = @project_floor.project
    @project_floor.destroy
    redirect_to project, notice: "Floor removed."
  end

  private

  def set_project
    @project = Project.find(params[:project_id])
  end

  def set_project_floor
    @project_floor = ProjectFloor.find(params[:id])
  end

  def project_floor_params
    params.require(:project_floor).permit(:floor_number, :name, :floor_height_ft, :footprint_percentage, :bhk_type)
  end
end
