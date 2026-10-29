class MaterialCategory < ApplicationRecord
  has_many :materials, dependent: :restrict_with_error

  validates :name, :code, presence: true
  validates :code, uniqueness: true

  default_scope { order(:position) }
end
