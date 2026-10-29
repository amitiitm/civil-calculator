class FormulaParameter < ApplicationRecord
  belongs_to :calculation_formula

  validates :key, presence: true
  validates :value, numericality: true
end
