FactoryBot.define do
  factory :room do
    project_floor
    room_type { :bedroom }
    sequence(:name) { |n| "Room #{n}" }
    length_ft { 12 }
    width_ft { 10 }
    wall_height_ft { 10 }
    door_count { 1 }
    window_count { 1 }
    electrical_point_count { 4 }
  end
end
