class Admin::ConstructionSettingsController < Admin::BaseController
  before_action :set_construction_setting, only: [ :edit, :update, :destroy ]

  def index
    @construction_settings = ConstructionSetting.order(:group, :key)
  end

  def new
    @construction_setting = ConstructionSetting.new
  end

  def create
    @construction_setting = ConstructionSetting.new(construction_setting_params)
    if @construction_setting.save
      redirect_to admin_construction_settings_path, notice: "Setting created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @construction_setting.update(construction_setting_params)
      redirect_to admin_construction_settings_path, notice: "Setting updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @construction_setting.destroy
    redirect_to admin_construction_settings_path, notice: "Setting removed."
  end

  private

  def set_construction_setting
    @construction_setting = ConstructionSetting.find(params[:id])
  end

  def construction_setting_params
    params.require(:construction_setting).permit(:key, :value, :data_type, :group, :description)
  end
end
