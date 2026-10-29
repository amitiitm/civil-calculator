FactoryBot.define do
  factory :project_floor do
    project
    sequence(:floor_number) { |n| n }
    name { "Ground Floor" }
    floor_height_ft { 10 }
  end
end
