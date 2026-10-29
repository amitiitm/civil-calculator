module Calculations
  # Looks up admin-configured CalculationFormula/FormulaParameter records instead of
  # hardcoding construction assumptions in service objects.
  module FormulaLookup
    private

    def formula_for(category_code)
      CalculationFormula.active.find_by(category_code: category_code) ||
        raise(MissingFormulaParameterError, "No active calculation formula configured for '#{category_code}'")
    end

    def parameter(formula, key, default: nil)
      value = formula.parameter(key)
      return value unless value.nil?
      return default unless default.nil?

      raise MissingFormulaParameterError, "Formula '#{formula.category_code}' is missing parameter '#{key}'"
    end
  end
end
