class DoorsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project_floor, only: [ :new, :create ]
  before_action :set_door, only: [ :edit, :update, :destroy ]

  def new
    @door = @project_floor.doors.build
    authorize @door
  end

  def create
    @door = @project_floor.doors.build(door_params)
    authorize @door

    if @door.save
      redirect_to @project_floor.project, notice: "Door added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @door
  end

  def update
    authorize @door

    if @door.update(door_params)
      redirect_to @door.project_floor.project, notice: "Door updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @door
    project = @door.project_floor.project
    @door.destroy
    redirect_to project, notice: "Door removed."
  end

  private

  def set_project_floor
    @project_floor = ProjectFloor.find(params[:project_floor_id])
  end

  def set_door
    @door = Door.find(params[:id])
  end

  def door_params
    params.require(:door).permit(:room_id, :door_type, :material, :width_ft, :height_ft, :quantity)
  end
end
