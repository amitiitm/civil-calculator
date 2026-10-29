FactoryBot.define do
  factory :project_actual_cost do
    project
    category { "Material" }
    description { "Actual cement purchase" }
    amount { 10_000 }
    recorded_on { Date.current }
  end
end
