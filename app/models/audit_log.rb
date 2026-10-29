class AuditLog < ApplicationRecord
  belongs_to :user, optional: true

  validates :action, :auditable_type, :auditable_id, presence: true
end
