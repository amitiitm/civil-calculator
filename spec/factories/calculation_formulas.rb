FactoryBot.define do
  factory :calculation_formula do
    sequence(:category_code) { |n| "category_#{n}" }
    name { "Test Formula" }
    formula_identifier { "test_formula" }
    version { 1 }
    active { true }

    trait :bricks do
      category_code { "bricks" }

      after(:create) do |formula|
        formula.formula_parameters.create!(key: "brick_length_in", value: 9, data_type: "decimal")
        formula.formula_parameters.create!(key: "brick_width_in", value: 4.25, data_type: "decimal")
        formula.formula_parameters.create!(key: "brick_height_in", value: 3, data_type: "decimal")
        formula.formula_parameters.create!(key: "mortar_thickness_in", value: 0.5, data_type: "decimal")
      end
    end

    trait :cement_mix do
      after(:create) do |formula|
        formula.formula_parameters.create!(key: "cement_ratio", value: 1, data_type: "decimal")
        formula.formula_parameters.create!(key: "sand_ratio", value: 2, data_type: "decimal")
        formula.formula_parameters.create!(key: "aggregate_ratio", value: 4, data_type: "decimal")
        formula.formula_parameters.create!(key: "dry_volume_factor", value: 1.54, data_type: "decimal")
        formula.formula_parameters.create!(key: "cement_bag_volume_cft", value: 1.25, data_type: "decimal")
      end
    end

    trait :mortar_mix do
      after(:create) do |formula|
        formula.formula_parameters.create!(key: "cement_ratio", value: 1, data_type: "decimal")
        formula.formula_parameters.create!(key: "sand_ratio", value: 6, data_type: "decimal")
        formula.formula_parameters.create!(key: "aggregate_ratio", value: 0, data_type: "decimal")
        formula.formula_parameters.create!(key: "dry_volume_factor", value: 1.33, data_type: "decimal")
        formula.formula_parameters.create!(key: "cement_bag_volume_cft", value: 1.25, data_type: "decimal")
      end
    end

    trait :steel do
      after(:create) do |formula|
        formula.formula_parameters.create!(key: "kg_per_cft", value: 5, data_type: "decimal")
      end
    end
  end
end
