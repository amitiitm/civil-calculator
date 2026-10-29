FactoryBot.define do
  factory :project do
    user
    sequence(:name) { |n| "Project #{n}" }
    client_name { "Demo Client" }
    city { "Pune" }
    state { "Maharashtra" }
    plot_length_ft { 40 }
    plot_width_ft { 60 }
    construction_length_ft { 30 }
    construction_width_ft { 50 }
    floors_count { 1 }
    bhk_type { :bhk_2 }
    construction_quality { :standard }
    status { :draft }
  end
end
