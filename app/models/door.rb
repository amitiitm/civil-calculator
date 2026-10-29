class Door < ApplicationRecord
  belongs_to :project_floor
  belongs_to :room, optional: true

  enum :door_type, { main_entrance: 0, bedroom: 1, bathroom: 2, balcony: 3, sliding: 4, custom: 5 }
  enum :material, { teak_wood: 0, sal_wood: 1, flush_door: 2, wpc: 3, pvc: 4, aluminium: 5, steel: 6 }

  validates :width_ft, :height_ft, numericality: { greater_than: 0 }
  validates :quantity, numericality: { greater_than: 0, only_integer: true }

  def area_sqft
    width_ft * height_ft * quantity
  end
end
