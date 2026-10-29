class Admin::LabourRatesController < Admin::BaseController
  before_action :set_labour_rate, only: [ :edit, :update, :destroy ]

  def index
    @labour_rates = LabourRate.all
  end

  def new
    @labour_rate = LabourRate.new
  end

  def create
    @labour_rate = LabourRate.new(labour_rate_params)
    if @labour_rate.save
      redirect_to admin_labour_rates_path, notice: "Labour rate created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @labour_rate.update(labour_rate_params)
      redirect_to admin_labour_rates_path, notice: "Labour rate updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @labour_rate.destroy
    redirect_to admin_labour_rates_path, notice: "Labour rate removed."
  end

  private

  def set_labour_rate
    @labour_rate = LabourRate.find(params[:id])
  end

  def labour_rate_params
    params.require(:labour_rate).permit(:work_type, :unit, :rate, :city, :state, :quality_grade, :active)
  end
end
