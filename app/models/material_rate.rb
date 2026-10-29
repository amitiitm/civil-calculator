class MaterialRate < ApplicationRecord
  belongs_to :material

  validates :rate, numericality: { greater_than_or_equal_to: 0 }
  validates :effective_date, presence: true
end
