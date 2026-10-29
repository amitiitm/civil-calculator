FactoryBot.define do
  factory :formula_parameter do
    calculation_formula
    sequence(:key) { |n| "param_#{n}" }
    value { 1 }
    data_type { "decimal" }
  end
end
