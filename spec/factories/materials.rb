FactoryBot.define do
  factory :material do
    material_category
    sequence(:code) { |n| "MAT-#{n}" }
    name { "Test Material" }
    unit { "nos" }
    default_rate { 10 }
    wastage_percentage { 5 }
    quality_grade { "standard" }
    brand { "Generic" }
    formula_identifier { "bricks" }
    effective_date { Date.current }
    active { true }
  end
end
