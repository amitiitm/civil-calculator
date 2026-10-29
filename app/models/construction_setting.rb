class ConstructionSetting < ApplicationRecord
  validates :key, :value, :data_type, presence: true
  validates :key, uniqueness: { case_sensitive: false }

  # Admin-configurable construction assumptions (wall thickness, slab thickness, etc),
  # type-cast according to the stored data_type so callers never parse raw strings.
  def self.fetch(key, default = nil)
    setting = find_by(key: key)
    return default if setting.nil?

    setting.typed_value
  end

  def typed_value
    case data_type
    when "integer" then value.to_i
    when "decimal", "float" then BigDecimal(value)
    when "boolean" then ActiveModel::Type::Boolean.new.cast(value)
    else value
    end
  end
end
