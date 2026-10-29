module Calculations
  # Raised when an admin-configurable formula or one of its parameters is missing.
  class MissingFormulaParameterError < CalculationError; end
end
