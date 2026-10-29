class ProjectFloor < ApplicationRecord
  belongs_to :project
  has_many :rooms, dependent: :destroy
  has_many :doors, dependent: :destroy
  has_many :windows, dependent: :destroy

  # Drives this floor's average door/window allowance; blank/custom_layout means
  # no automatic door/window line items are generated for this floor.
  enum :bhk_type, { bhk_1: 0, bhk_2: 1, bhk_3: 2, bhk_4: 3, custom_layout: 4 }, default: nil

  validates :floor_number, presence: true, uniqueness: { scope: :project_id }
  validates :floor_height_ft, numericality: { greater_than: 0 }
  validates :footprint_percentage, numericality: { greater_than: 0, less_than_or_equal_to: 100 }

  def total_room_area_sqft
    rooms.sum(&:area_sqft)
  end

  # This floor's share of the project's construction footprint - less than 100%
  # for a partial top floor (e.g. the ".5" in a 2.5-floor project).
  def footprint_sqft
    project.construction_footprint_sqft * footprint_percentage / 100
  end

  # Flags layouts whose room area exceeds the floor's share of the built-up area;
  # does not assert the layout is architecturally feasible.
  def exceeds_built_up_area?
    total_room_area_sqft > footprint_sqft
  end

  def uses_average_doors_windows?
    bhk_type.present? && !custom_layout?
  end
end
