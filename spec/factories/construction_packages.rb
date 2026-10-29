FactoryBot.define do
  factory :construction_package do
    sequence(:slug) { |n| "package-#{n}" }
    sequence(:name) { |n| "Package #{n}" }
    description { "Illustrative package" }
    rate_per_sqft { 1500 }
    position { 1 }
    active { true }
  end
end
