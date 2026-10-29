class Window < ApplicationRecord
  belongs_to :project_floor
  belongs_to :room, optional: true

  enum :window_type, {
    aluminium: 0, upvc: 1, wooden: 2, steel: 3, sliding_glass: 4, casement: 5, premium_double_glazed: 6
  }

  validates :width_ft, :height_ft, numericality: { greater_than: 0 }
  validates :quantity, numericality: { greater_than: 0, only_integer: true }

  def area_sqft
    width_ft * height_ft * quantity
  end
end
