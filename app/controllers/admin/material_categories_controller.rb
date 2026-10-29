class Admin::MaterialCategoriesController < Admin::BaseController
  before_action :set_material_category, only: [ :edit, :update, :destroy ]

  def index
    @material_categories = MaterialCategory.all
  end

  def new
    @material_category = MaterialCategory.new
  end

  def create
    @material_category = MaterialCategory.new(material_category_params)
    if @material_category.save
      redirect_to admin_material_categories_path, notice: "Category created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @material_category.update(material_category_params)
      redirect_to admin_material_categories_path, notice: "Category updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @material_category.destroy
    redirect_to admin_material_categories_path, notice: "Category removed."
  rescue ActiveRecord::DeleteRestrictionError
    redirect_to admin_material_categories_path, alert: "Cannot delete a category that still has materials."
  end

  private

  def set_material_category
    @material_category = MaterialCategory.find(params[:id])
  end

  def material_category_params
    params.require(:material_category).permit(:name, :code, :description, :position)
  end
end
