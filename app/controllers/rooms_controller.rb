class RoomsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project_floor, only: [ :new, :create ]
  before_action :set_room, only: [ :edit, :update, :destroy ]

  def new
    @room = @project_floor.rooms.build
    authorize @room
  end

  def create
    @room = @project_floor.rooms.build(room_params)
    authorize @room

    if @room.save
      redirect_to @project_floor.project, notice: "Room added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @room
  end

  def update
    authorize @room

    if @room.update(room_params)
      redirect_to @room.project_floor.project, notice: "Room updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @room
    project = @room.project_floor.project
    @room.destroy
    redirect_to project, notice: "Room removed."
  end

  private

  def set_project_floor
    @project_floor = ProjectFloor.find(params[:project_floor_id])
  end

  def set_room
    @room = Room.find(params[:id])
  end

  def room_params
    params.require(:room).permit(
      :room_type, :name, :length_ft, :width_ft, :wall_height_ft,
      :door_count, :window_count, :electrical_point_count
    )
  end
end
