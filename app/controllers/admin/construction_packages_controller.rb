class Admin::ConstructionPackagesController < Admin::BaseController
  before_action :set_construction_package, only: [ :edit, :update, :destroy ]

  def index
    @construction_packages = ConstructionPackage.all
  end

  def new
    @construction_package = ConstructionPackage.new
  end

  def create
    @construction_package = ConstructionPackage.new(construction_package_params)
    if @construction_package.save
      redirect_to admin_construction_packages_path, notice: "Package created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @construction_package.update(construction_package_params)
      redirect_to admin_construction_packages_path, notice: "Package updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @construction_package.destroy
    redirect_to admin_construction_packages_path, notice: "Package removed."
  end

  private

  def set_construction_package
    @construction_package = ConstructionPackage.find(params[:id])
  end

  def construction_package_params
    params.require(:construction_package).permit(:name, :slug, :description, :rate_per_sqft, :position, :active)
  end
end
