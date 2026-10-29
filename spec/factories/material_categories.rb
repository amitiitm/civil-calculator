FactoryBot.define do
  factory :material_category do
    sequence(:code) { |n| "category-#{n}" }
    sequence(:name) { |n| "Category #{n}" }
    position { 1 }
  end
end
