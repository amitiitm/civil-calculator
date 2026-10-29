class LabourRate < ApplicationRecord
  validates :work_type, :unit, presence: true
  validates :rate, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }
end
