class Estimate < ApplicationRecord
  belongs_to :project
  belongs_to :user
  belongs_to :construction_package, optional: true
  belongs_to :previous_version, class_name: "Estimate", optional: true
  has_many :revisions, class_name: "Estimate", foreign_key: :previous_version_id, dependent: :nullify, inverse_of: :previous_version
  has_many :estimate_line_items, dependent: :destroy

  enum :status, { draft: 0, final: 1 }

  validates :version_number, presence: true
  validates :price_date, presence: true

  # Recomputes cost breakdown from line items so every displayed total
  # reconciles with the underlying estimate_line_items.
  def recalculate_totals!
    grouped = estimate_line_items.group(:item_type).sum(:amount)
    self.material_cost = grouped["material"] || 0
    self.labour_cost = grouped["labour"] || 0
    self.equipment_cost = grouped["equipment"] || 0
    self.transport_cost = grouped["other"] || 0

    subtotal = material_cost + labour_cost + equipment_cost + transport_cost
    self.contingency_amount = subtotal * (contingency_percentage / 100)
    self.total_cost = subtotal + contingency_amount + tax_amount
    self.cost_per_sqft = project.total_built_up_area_sqft.positive? ? (total_cost / project.total_built_up_area_sqft) : 0
    save!
  end
end
