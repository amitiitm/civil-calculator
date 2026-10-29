FactoryBot.define do
  factory :estimate do
    project
    user
    construction_package
    version_number { 1 }
    status { :draft }
    price_date { Date.current }
    contingency_percentage { 5 }
  end
end
