class Admin::FormulaParametersController < Admin::BaseController
  before_action :set_calculation_formula
  before_action :set_formula_parameter, only: [ :edit, :update, :destroy ]

  def new
    @formula_parameter = @calculation_formula.formula_parameters.build
  end

  def create
    @formula_parameter = @calculation_formula.formula_parameters.build(formula_parameter_params)
    if @formula_parameter.save
      redirect_to admin_calculation_formula_path(@calculation_formula), notice: "Parameter added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit; end

  def update
    if @formula_parameter.update(formula_parameter_params)
      redirect_to admin_calculation_formula_path(@calculation_formula), notice: "Parameter updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @formula_parameter.destroy
    redirect_to admin_calculation_formula_path(@calculation_formula), notice: "Parameter removed."
  end

  private

  def set_calculation_formula
    @calculation_formula = CalculationFormula.find(params[:calculation_formula_id])
  end

  def set_formula_parameter
    @formula_parameter = @calculation_formula.formula_parameters.find(params[:id])
  end

  def formula_parameter_params
    params.require(:formula_parameter).permit(:key, :value, :data_type)
  end
end
