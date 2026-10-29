class Material < ApplicationRecord
  belongs_to :material_category
  has_many :material_rates, dependent: :destroy

  validates :code, :name, :unit, :formula_identifier, presence: true
  validates :code, uniqueness: { case_sensitive: false }
  validates :default_rate, :wastage_percentage, numericality: { greater_than_or_equal_to: 0 }

  scope :active, -> { where(active: true) }

  # Rate for the given location/quality, falling back to the material's default rate.
  def rate_for(state: nil, city: nil, quality_grade: nil)
    scope = material_rates.where(quality_grade: quality_grade || self.quality_grade)
    scope = scope.where(state: state) if state.present?
    scope = scope.where(city: city) if city.present?
    scope.order(effective_date: :desc).first&.rate || default_rate
  end
end
