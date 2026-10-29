FactoryBot.define do
  factory :material_rate do
    material
    state { "Maharashtra" }
    city { "Pune" }
    quality_grade { "standard" }
    rate { 10 }
    effective_date { Date.current }
  end
end
