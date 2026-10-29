FactoryBot.define do
  factory :estimate_line_item do
    estimate
    material_category_name { "bricks" }
    item_name { "Red Clay Brick" }
    unit { "nos" }
    raw_quantity { 100 }
    purchase_quantity { 105 }
    rate { 8 }
    item_type { :material }
    data_source { :calculated }
    floor_label { "Ground Floor" }
    formula_identifier { "bricks" }
  end
end
