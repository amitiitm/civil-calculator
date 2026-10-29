class CalculationFormula < ApplicationRecord
  has_many :formula_parameters, dependent: :destroy

  validates :category_code, :name, :formula_identifier, presence: true
  validates :version, numericality: { greater_than: 0 }

  scope :active, -> { where(active: true) }

  def parameter(key)
    formula_parameters.find_by(key: key)&.value
  end
end
