FactoryBot.define do
  factory :door do
    project_floor
    room { nil }
    door_type { :main_entrance }
    material { :teak_wood }
    width_ft { 3.5 }
    height_ft { 7 }
    quantity { 1 }
  end
end
