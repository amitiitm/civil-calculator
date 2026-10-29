class Room < ApplicationRecord
  belongs_to :project_floor
  has_many :doors, dependent: :destroy
  has_many :windows, dependent: :destroy

  enum :room_type, {
    bedroom: 0, master_bedroom: 1, living_room: 2, kitchen: 3, bathroom: 4,
    toilet: 5, dining_room: 6, store_room: 7, balcony: 8, other: 9
  }

  validates :name, presence: true
  validates :length_ft, :width_ft, numericality: { greater_than: 0 }
  validates :wall_height_ft, numericality: { greater_than: 0 }
  validates :door_count, :window_count, :electrical_point_count, numericality: { greater_than_or_equal_to: 0 }

  def area_sqft
    length_ft * width_ft
  end

  def perimeter_ft
    2 * (length_ft + width_ft)
  end

  def wall_area_sqft
    perimeter_ft * wall_height_ft
  end
end
