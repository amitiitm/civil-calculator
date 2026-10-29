class Admin::CalculationFormulasController < Admin::BaseController
  before_action :set_calculation_formula, only: [ :show, :edit, :update, :destroy ]

  def index
    @calculation_formulas = CalculationFormula.order(:category_code, :version)
  end

  def show
    @formula_parameters = @calculation_formula.formula_parameters
  end

  def new
    @calculation_formula = CalculationFormula.new
  end

  def create
    @calculation_formula = CalculationFormula.new(calculation_formula_params)
    if @calculation_formula.save
      redirect_to admin_calculation_formula_path(@calculation_formula), notice: "Formula created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @calculation_formula.update(calculation_formula_params)
      redirect_to admin_calculation_formula_path(@calculation_formula), notice: "Formula updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @calculation_formula.destroy
    redirect_to admin_calculation_formulas_path, notice: "Formula removed."
  end

  private

  def set_calculation_formula
    @calculation_formula = CalculationFormula.find(params[:id])
  end

  def calculation_formula_params
    params.require(:calculation_formula).permit(:category_code, :name, :formula_identifier, :version, :active, :description)
  end
end
