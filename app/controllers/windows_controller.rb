class WindowsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_project_floor, only: [ :new, :create ]
  before_action :set_window, only: [ :edit, :update, :destroy ]

  def new
    @window = @project_floor.windows.build
    authorize @window
  end

  def create
    @window = @project_floor.windows.build(window_params)
    authorize @window

    if @window.save
      redirect_to @project_floor.project, notice: "Window added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    authorize @window
  end

  def update
    authorize @window

    if @window.update(window_params)
      redirect_to @window.project_floor.project, notice: "Window updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    authorize @window
    project = @window.project_floor.project
    @window.destroy
    redirect_to project, notice: "Window removed."
  end

  private

  def set_project_floor
    @project_floor = ProjectFloor.find(params[:project_floor_id])
  end

  def set_window
    @window = Window.find(params[:id])
  end

  def window_params
    params.require(:window).permit(:room_id, :window_type, :width_ft, :height_ft, :quantity)
  end
end
