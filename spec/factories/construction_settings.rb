FactoryBot.define do
  factory :construction_setting do
    sequence(:key) { |n| "setting_key_#{n}" }
    value { "10" }
    data_type { "decimal" }
    group { "walls" }
    description { "Test setting" }
  end
end
