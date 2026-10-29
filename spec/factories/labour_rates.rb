FactoryBot.define do
  factory :labour_rate do
    sequence(:work_type) { |n| "Labour Type #{n}" }
    unit { "sqft" }
    rate { 15 }
    city { "Pune" }
    state { "Maharashtra" }
    quality_grade { "standard" }
    active { true }
  end
end
