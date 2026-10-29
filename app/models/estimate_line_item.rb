class EstimateLineItem < ApplicationRecord
  belongs_to :estimate

  enum :item_type, { material: 0, labour: 1, equipment: 2, other: 3 }
  enum :data_source, { calculated: 0, assumed: 1, manual: 2, engineer_verified: 3 }

  validates :item_name, :unit, :formula_identifier, presence: true
  validates :purchase_quantity, :rate, numericality: { greater_than_or_equal_to: 0 }

  before_validation :compute_amount

  # Groups activity-specific codes (cement_masonry, cement_rcc, ...) under one
  # material for project-wide totals (cement, sand, aggregate, steel, bricks, ...).
  def base_category
    material_category_name.split("_").first
  end

  private

  def compute_amount
    self.amount = (purchase_quantity || 0) * (rate || 0)
  end
end
