class ProjectActualCost < ApplicationRecord
  belongs_to :project

  validates :category, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0 }
  validates :recorded_on, presence: true
end
