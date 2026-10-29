class ConstructionPackage < ApplicationRecord
  has_many :estimates, dependent: :nullify

  validates :name, :slug, presence: true
  validates :slug, uniqueness: true
  validates :rate_per_sqft, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }
  default_scope { order(:position) }
end
