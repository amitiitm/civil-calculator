class Project < ApplicationRecord
  belongs_to :user
  has_many :project_floors, -> { order(:floor_number) }, dependent: :destroy
  has_many :estimates, dependent: :destroy
  has_many :project_actual_costs, dependent: :destroy

  enum :bhk_type, { bhk_1: 0, bhk_2: 1, bhk_3: 2, bhk_4: 3, custom_layout: 4 }
  enum :construction_quality, { economy: 0, standard: 1, premium: 2, luxury: 3 }
  enum :status, { draft: 0, active: 1, archived: 2 }

  validates :name, presence: true
  validates :plot_length_ft, :plot_width_ft, :construction_length_ft, :construction_width_ft,
            numericality: { greater_than: 0 }
  validates :floors_count, numericality: { greater_than: 0 }
  validate :floors_count_in_half_steps
  validate :construction_footprint_within_plot

  def plot_area_sqft
    plot_length_ft * plot_width_ft
  end

  def construction_footprint_sqft
    construction_length_ft * construction_width_ft
  end

  def total_built_up_area_sqft
    construction_footprint_sqft * floors_count
  end

  # 2.5 floors means 2 full floors plus a top floor covering half the footprint.
  def full_floors_count
    floors_count.floor
  end

  def partial_top_floor?
    floors_count.nil? ? false : (floors_count - full_floors_count) >= 0.5
  end

  private

  def floors_count_in_half_steps
    return if floors_count.blank?
    return if (floors_count * 2) == (floors_count * 2).round

    errors.add(:floors_count, "must be in half-floor increments (e.g. 1, 1.5, 2, 2.5)")
  end

  def construction_footprint_within_plot
    return if plot_length_ft.blank? || plot_width_ft.blank?
    return if construction_length_ft.blank? || construction_width_ft.blank?
    return if construction_footprint_sqft <= plot_area_sqft

    errors.add(:base, "Construction footprint exceeds plot area; account for setbacks and open spaces")
  end
end
