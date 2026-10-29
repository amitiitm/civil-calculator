FactoryBot.define do
  factory :window do
    project_floor
    room { nil }
    window_type { :aluminium }
    width_ft { 4 }
    height_ft { 4 }
    quantity { 1 }
  end
end
