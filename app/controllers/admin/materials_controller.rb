class Admin::MaterialsController < Admin::BaseController
  before_action :set_material, only: [ :edit, :update, :destroy ]

  def index
    @materials = Material.includes(:material_category).order(:name)
  end

  def new
    @material = Material.new
  end

  def create
    @material = Material.new(material_params)
    if @material.save
      redirect_to admin_materials_path, notice: "Material created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @material.update(material_params)
      redirect_to admin_materials_path, notice: "Material updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @material.destroy
    redirect_to admin_materials_path, notice: "Material removed."
  end

  private

  def set_material
    @material = Material.find(params[:id])
  end

  def material_params
    params.require(:material).permit(
      :material_category_id, :code, :name, :unit, :default_rate, :wastage_percentage,
      :quality_grade, :brand, :formula_identifier, :supplier, :effective_date, :active
    )
  end
end
