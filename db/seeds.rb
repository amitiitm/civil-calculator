# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
#
# All rates below are illustrative sample data for demonstration only, not live market prices.

puts "Seeding material categories..."
CATEGORIES = {
  "bricks" => "Bricks & Blocks",
  "cement" => "Cement",
  "sand" => "Sand",
  "aggregate" => "Aggregate",
  "steel" => "Steel / TMT Bars",
  "tiles" => "Floor & Wall Tiles",
  "electrical" => "Electrical",
  "granite" => "Granite & Stone"
}.freeze

categories = CATEGORIES.map.with_index(1) do |(code, name), position|
  MaterialCategory.find_or_create_by!(code: code) { |c| c.name = name; c.position = position }
end.index_by(&:code)

puts "Seeding materials..."
MATERIALS = [
  { code: "BRICK-RED-STD", category: "bricks", name: "Red Clay Brick (Standard)", unit: "nos",
    default_rate: 8, wastage_percentage: 5, quality_grade: "standard", brand: "Local Kiln",
    formula_identifier: "bricks" },
  { code: "CEMENT-OPC-53", category: "cement", name: "OPC 53 Grade Cement", unit: "bags",
    default_rate: 420, wastage_percentage: 2, quality_grade: "standard", brand: "UltraTech",
    formula_identifier: "cement" },
  { code: "SAND-RIVER-STD", category: "sand", name: "River Sand", unit: "cft",
    default_rate: 55, wastage_percentage: 5, quality_grade: "standard", brand: "Local Supplier",
    formula_identifier: "sand" },
  { code: "AGG-20MM-STD", category: "aggregate", name: "20mm Aggregate", unit: "cft",
    default_rate: 45, wastage_percentage: 5, quality_grade: "standard", brand: "Local Quarry",
    formula_identifier: "aggregate" },
  { code: "STEEL-FE500-STD", category: "steel", name: "Fe500 TMT Bar", unit: "kg",
    default_rate: 68, wastage_percentage: 3, quality_grade: "standard", brand: "Tata Tiscon",
    formula_identifier: "steel" },
  { code: "TILE-ECONOMY", category: "tiles", name: "Economy Ceramic Tile", unit: "sqft",
    default_rate: 40, wastage_percentage: 5, quality_grade: "economy", brand: "Local",
    formula_identifier: "tiles" },
  { code: "TILE-STANDARD", category: "tiles", name: "Standard Vitrified Tile", unit: "sqft",
    default_rate: 50, wastage_percentage: 5, quality_grade: "standard", brand: "Kajaria",
    formula_identifier: "tiles" },
  { code: "TILE-PREMIUM", category: "tiles", name: "Premium Double-Charge Vitrified Tile", unit: "sqft",
    default_rate: 65, wastage_percentage: 5, quality_grade: "premium", brand: "Kajaria",
    formula_identifier: "tiles" },
  { code: "TILE-LUXURY", category: "tiles", name: "Luxury Designer Tile", unit: "sqft",
    default_rate: 100, wastage_percentage: 5, quality_grade: "luxury", brand: "Johnson",
    formula_identifier: "tiles" },
  { code: "ELEC-POINT-STD", category: "electrical", name: "Electrical Point (wiring, switch, fittings)", unit: "point",
    default_rate: 1200, wastage_percentage: 0, quality_grade: "standard", brand: "Generic",
    formula_identifier: "electrical" },
  { code: "GRANITE-STAIR-STD", category: "granite", name: "Staircase Granite", unit: "sqft",
    default_rate: 150, wastage_percentage: 5, quality_grade: "standard", brand: "Local Quarry",
    formula_identifier: "granite" }
].freeze

MATERIALS.each do |attrs|
  category = categories.fetch(attrs[:category])
  Material.find_or_create_by!(code: attrs[:code]) do |m|
    m.material_category = category
    m.name = attrs[:name]
    m.unit = attrs[:unit]
    m.default_rate = attrs[:default_rate]
    m.wastage_percentage = attrs[:wastage_percentage]
    m.quality_grade = attrs[:quality_grade]
    m.brand = attrs[:brand]
    m.formula_identifier = attrs[:formula_identifier]
    m.effective_date = Date.current
    m.active = true
  end
end

puts "Seeding construction settings..."
SETTINGS = [
  { key: "wall_thickness_external_in", value: "9", data_type: "decimal", group: "walls",
    description: "Default external wall thickness in inches" },
  { key: "wall_thickness_internal_in", value: "4.5", data_type: "decimal", group: "walls",
    description: "Default internal wall thickness in inches" },
  { key: "slab_thickness_in", value: "5", data_type: "decimal", group: "rcc",
    description: "Default RCC slab thickness in inches" },
  { key: "column_width_in", value: "9", data_type: "decimal", group: "rcc",
    description: "Illustrative preliminary column width in inches - verify with a structural engineer" },
  { key: "column_depth_in", value: "9", data_type: "decimal", group: "rcc",
    description: "Illustrative preliminary column depth in inches - verify with a structural engineer" },
  { key: "footing_length_ft", value: "4", data_type: "decimal", group: "rcc",
    description: "Illustrative preliminary footing length in feet" },
  { key: "footing_width_ft", value: "4", data_type: "decimal", group: "rcc",
    description: "Illustrative preliminary footing width in feet" },
  { key: "footing_depth_ft", value: "3", data_type: "decimal", group: "rcc",
    description: "Illustrative preliminary footing depth in feet" },
  { key: "default_column_count_per_floor", value: "4", data_type: "integer", group: "rcc",
    description: "Illustrative column count suggestion - never sufficient on its own for structural design" },
  { key: "default_contingency_percentage", value: "5", data_type: "decimal", group: "cost",
    description: "Default contingency percentage applied to every estimate" },
  { key: "avg_door_count_bhk_1", value: "5", data_type: "integer", group: "doors_windows",
    description: "Average door count for a 1 BHK layout" },
  { key: "avg_door_count_bhk_2", value: "7", data_type: "integer", group: "doors_windows",
    description: "Average door count for a 2 BHK layout (incl. 2 bathrooms)" },
  { key: "avg_door_count_bhk_3", value: "9", data_type: "integer", group: "doors_windows",
    description: "Average door count for a 3 BHK layout" },
  { key: "avg_door_count_bhk_4", value: "11", data_type: "integer", group: "doors_windows",
    description: "Average door count for a 4 BHK layout" },
  { key: "avg_window_count_bhk_1", value: "3", data_type: "integer", group: "doors_windows",
    description: "Average window count for a 1 BHK layout" },
  { key: "avg_window_count_bhk_2", value: "5", data_type: "integer", group: "doors_windows",
    description: "Average window count for a 2 BHK layout (incl. 2 bathrooms)" },
  { key: "avg_window_count_bhk_3", value: "7", data_type: "integer", group: "doors_windows",
    description: "Average window count for a 3 BHK layout" },
  { key: "avg_window_count_bhk_4", value: "9", data_type: "integer", group: "doors_windows",
    description: "Average window count for a 4 BHK layout" },
  { key: "average_door_width_ft", value: "7", data_type: "decimal", group: "doors_windows",
    description: "Average door width in feet, used for overall project estimate" },
  { key: "average_door_height_ft", value: "3.5", data_type: "decimal", group: "doors_windows",
    description: "Average door height in feet, used for overall project estimate" },
  { key: "average_window_width_ft", value: "5", data_type: "decimal", group: "doors_windows",
    description: "Average window width in feet, used for overall project estimate" },
  { key: "average_window_height_ft", value: "4", data_type: "decimal", group: "doors_windows",
    description: "Average window height in feet, used for overall project estimate" },
  { key: "door_cost_with_chokhat", value: "7000", data_type: "decimal", group: "doors_windows",
    description: "Average flat cost per door including frame (chokhat), in INR" },
  { key: "window_rate_aluminium_per_sqft", value: "250", data_type: "decimal", group: "doors_windows",
    description: "Average aluminium window rate per sqft, in INR" },
  { key: "window_rate_upvc_per_sqft", value: "500", data_type: "decimal", group: "doors_windows",
    description: "Average UPVC window rate per sqft, in INR" },
  { key: "washroom_tile_allowance_sqft", value: "250", data_type: "decimal", group: "flooring",
    description: "Flat tile area allowance (floor + wall) per washroom, in sqft" },
  { key: "tile_area_multiplier_other_rooms", value: "1.2", data_type: "decimal", group: "flooring",
    description: "Tile area as a multiple of carpet area for non-washroom rooms (covers wastage/cutting)" },
  { key: "stair_steps_per_floor", value: "19", data_type: "integer", group: "staircase",
    description: "Average steps per flight of stairs (one flight per full floor, plus one for a partial floor)" },
  { key: "stair_granite_sqinch_per_step", value: "800", data_type: "decimal", group: "staircase",
    description: "Granite area per step in square inches (tread + riser)" }
].freeze

SETTINGS.each do |attrs|
  ConstructionSetting.find_or_create_by!(key: attrs[:key]) do |s|
    s.value = attrs[:value]
    s.data_type = attrs[:data_type]
    s.group = attrs[:group]
    s.description = attrs[:description]
  end
end

puts "Seeding calculation formulas..."
FORMULAS = [
  { category_code: "bricks", name: "Standard brick masonry", formula_identifier: "net_volume_over_effective_brick_volume",
    parameters: { "brick_length_in" => 9, "brick_width_in" => 4.25, "brick_height_in" => 3, "mortar_thickness_in" => 0.5 } },
  { category_code: "cement_masonry", name: "Brick masonry mortar mix", formula_identifier: "dry_volume_mix",
    parameters: { "cement_ratio" => 1, "sand_ratio" => 6, "aggregate_ratio" => 0, "dry_volume_factor" => 1.33,
                  "cement_bag_volume_cft" => 1.25 } },
  { category_code: "cement_plaster", name: "Plaster mix", formula_identifier: "dry_volume_mix",
    parameters: { "cement_ratio" => 1, "sand_ratio" => 4, "aggregate_ratio" => 0, "dry_volume_factor" => 1.33,
                  "cement_bag_volume_cft" => 1.25 } },
  { category_code: "cement_flooring", name: "Floor bedding mix", formula_identifier: "dry_volume_mix",
    parameters: { "cement_ratio" => 1, "sand_ratio" => 4, "aggregate_ratio" => 0, "dry_volume_factor" => 1.33,
                  "cement_bag_volume_cft" => 1.25 } },
  { category_code: "cement_screed", name: "Screed mix", formula_identifier: "dry_volume_mix",
    parameters: { "cement_ratio" => 1, "sand_ratio" => 3, "aggregate_ratio" => 0, "dry_volume_factor" => 1.33,
                  "cement_bag_volume_cft" => 1.25 } },
  { category_code: "cement_rcc", name: "RCC concrete mix (M20 illustrative)", formula_identifier: "dry_volume_mix",
    parameters: { "cement_ratio" => 1, "sand_ratio" => 2, "aggregate_ratio" => 4, "dry_volume_factor" => 1.54,
                  "cement_bag_volume_cft" => 1.25 } },
  { category_code: "steel_footing", name: "Preliminary footing steel factor", formula_identifier: "kg_per_cft_concrete",
    parameters: { "kg_per_cft" => 2.5 } },
  { category_code: "steel_column", name: "Preliminary column steel factor", formula_identifier: "kg_per_cft_concrete",
    parameters: { "kg_per_cft" => 5.0 } },
  { category_code: "steel_beam", name: "Preliminary beam steel factor", formula_identifier: "kg_per_cft_concrete",
    parameters: { "kg_per_cft" => 4.5 } },
  { category_code: "steel_slab", name: "Preliminary slab steel factor", formula_identifier: "kg_per_cft_concrete",
    parameters: { "kg_per_cft" => 2.5 } },
  { category_code: "steel_staircase", name: "Preliminary staircase steel factor", formula_identifier: "kg_per_cft_concrete",
    parameters: { "kg_per_cft" => 4.0 } }
].freeze

FORMULAS.each do |attrs|
  formula = CalculationFormula.find_or_create_by!(category_code: attrs[:category_code], version: 1) do |f|
    f.name = attrs[:name]
    f.formula_identifier = attrs[:formula_identifier]
    f.active = true
  end

  attrs[:parameters].each do |key, value|
    FormulaParameter.find_or_create_by!(calculation_formula: formula, key: key) do |p|
      p.value = value
      p.data_type = "decimal"
    end
  end
end

puts "Seeding construction packages..."
PACKAGES = [
  { slug: "economy", name: "Economy", rate_per_sqft: 1450, position: 1,
    description: "Basic fittings, standard bricks, economy tiles and paint." },
  { slug: "standard", name: "Standard", rate_per_sqft: 1850, position: 2,
    description: "Vitrified tiles, branded electricals, acrylic emulsion paint." },
  { slug: "premium", name: "Premium", rate_per_sqft: 2300, position: 3,
    description: "Premium granite, modular kitchen provision, premium emulsion paint." },
  { slug: "luxury", name: "Luxury", rate_per_sqft: 2900, position: 4,
    description: "Imported marble/granite, false ceiling, luxury emulsion, premium modular electricals." }
].freeze

PACKAGES.each do |attrs|
  ConstructionPackage.find_or_create_by!(slug: attrs[:slug]) do |p|
    p.name = attrs[:name]
    p.rate_per_sqft = attrs[:rate_per_sqft]
    p.position = attrs[:position]
    p.description = attrs[:description]
    p.active = true
  end
end

puts "Seeding labour rates..."
LABOUR_RATES = [
  { work_type: "General Construction Labour", unit: "sqft", rate: 350 },
  { work_type: "Mason (Brickwork)", unit: "cft", rate: 12 },
  { work_type: "Mason (Plaster)", unit: "sqft", rate: 15 },
  { work_type: "RCC Labour", unit: "cft", rate: 20 },
  { work_type: "Painter", unit: "sqft", rate: 10 },
  { work_type: "Tile Fixer", unit: "sqft", rate: 25 },
  { work_type: "Electrician", unit: "point", rate: 350 },
  { work_type: "Plumber", unit: "point", rate: 450 }
].freeze

LABOUR_RATES.each do |attrs|
  LabourRate.find_or_create_by!(work_type: attrs[:work_type]) do |l|
    l.unit = attrs[:unit]
    l.rate = attrs[:rate]
    l.active = true
  end
end

if Rails.env.development?
  puts "Seeding development admin user..."
  User.find_or_create_by!(email: "admin@buildestimate.test") do |u|
    u.name = "BuildEstimate Admin"
    u.password = "Password123!"
    u.role = :admin
  end
  puts "Dev admin login -> admin@buildestimate.test / Password123! (change before any shared use)"
end

puts "Seed complete."
