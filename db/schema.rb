# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_10_27_182844) do
  create_table "audit_logs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id"
    t.string "action", null: false
    t.string "auditable_type", null: false
    t.integer "auditable_id", null: false
    t.text "changes_json"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auditable_type", "auditable_id"], name: "index_audit_logs_on_auditable_type_and_auditable_id"
    t.index ["user_id"], name: "index_audit_logs_on_user_id"
  end

  create_table "calculation_formulas", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "category_code", null: false
    t.string "name", null: false
    t.string "formula_identifier", null: false
    t.integer "version", default: 1, null: false
    t.boolean "active", default: true, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["category_code", "version"], name: "index_calculation_formulas_on_category_code_and_version", unique: true
  end

  create_table "construction_packages", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "slug", null: false
    t.text "description"
    t.decimal "rate_per_sqft", precision: 12, scale: 2, default: "0.0", null: false
    t.integer "position", default: 0, null: false
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_construction_packages_on_slug", unique: true
  end

  create_table "construction_settings", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "key", null: false
    t.string "value", null: false
    t.string "data_type", default: "string", null: false
    t.string "group"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_construction_settings_on_key", unique: true
  end

  create_table "doors", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "project_floor_id", null: false
    t.bigint "room_id"
    t.integer "door_type", null: false
    t.integer "material", null: false
    t.decimal "width_ft", precision: 5, scale: 2, null: false
    t.decimal "height_ft", precision: 5, scale: 2, null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_floor_id"], name: "index_doors_on_project_floor_id"
    t.index ["room_id"], name: "index_doors_on_room_id"
  end

  create_table "estimate_line_items", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "estimate_id", null: false
    t.string "material_category_name", null: false
    t.string "item_name", null: false
    t.string "unit", null: false
    t.decimal "raw_quantity", precision: 14, scale: 4, default: "0.0", null: false
    t.decimal "purchase_quantity", precision: 14, scale: 4, default: "0.0", null: false
    t.decimal "rate", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "amount", precision: 14, scale: 2, default: "0.0", null: false
    t.integer "item_type", default: 0, null: false
    t.integer "data_source", default: 0, null: false
    t.string "floor_label"
    t.string "formula_identifier", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["estimate_id"], name: "index_estimate_line_items_on_estimate_id"
  end

  create_table "estimates", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.bigint "user_id", null: false
    t.bigint "construction_package_id"
    t.bigint "previous_version_id"
    t.integer "version_number", default: 1, null: false
    t.integer "status", default: 0, null: false
    t.decimal "material_cost", precision: 14, scale: 2, default: "0.0", null: false
    t.decimal "labour_cost", precision: 14, scale: 2, default: "0.0", null: false
    t.decimal "equipment_cost", precision: 14, scale: 2, default: "0.0", null: false
    t.decimal "transport_cost", precision: 14, scale: 2, default: "0.0", null: false
    t.decimal "contingency_percentage", precision: 5, scale: 2, default: "5.0", null: false
    t.decimal "contingency_amount", precision: 14, scale: 2, default: "0.0", null: false
    t.decimal "tax_amount", precision: 14, scale: 2, default: "0.0", null: false
    t.decimal "total_cost", precision: 14, scale: 2, default: "0.0", null: false
    t.decimal "cost_per_sqft", precision: 10, scale: 2, default: "0.0", null: false
    t.date "price_date", null: false
    t.text "assumptions_notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["construction_package_id"], name: "index_estimates_on_construction_package_id"
    t.index ["previous_version_id"], name: "index_estimates_on_previous_version_id"
    t.index ["project_id"], name: "index_estimates_on_project_id"
    t.index ["user_id"], name: "index_estimates_on_user_id"
  end

  create_table "formula_parameters", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "calculation_formula_id", null: false
    t.string "key", null: false
    t.decimal "value", precision: 14, scale: 4, null: false
    t.string "data_type", default: "decimal", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["calculation_formula_id", "key"], name: "index_formula_parameters_on_formula_and_key", unique: true
    t.index ["calculation_formula_id"], name: "index_formula_parameters_on_calculation_formula_id"
  end

  create_table "labour_rates", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "work_type"
    t.string "unit"
    t.decimal "rate", precision: 12, scale: 2
    t.string "city"
    t.string "state"
    t.string "quality_grade"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "material_categories", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "name", null: false
    t.string "code", null: false
    t.text "description"
    t.integer "position", default: 0, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_material_categories_on_code", unique: true
  end

  create_table "material_rates", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "material_id", null: false
    t.string "state"
    t.string "city"
    t.string "quality_grade"
    t.decimal "rate", precision: 12, scale: 2, null: false
    t.date "effective_date", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["material_id", "state", "city", "quality_grade"], name: "index_material_rates_on_location_and_grade"
    t.index ["material_id"], name: "index_material_rates_on_material_id"
  end

  create_table "materials", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "material_category_id", null: false
    t.string "code", null: false
    t.string "name", null: false
    t.string "unit", null: false
    t.decimal "default_rate", precision: 12, scale: 2, default: "0.0", null: false
    t.decimal "wastage_percentage", precision: 5, scale: 2, default: "0.0", null: false
    t.string "quality_grade"
    t.string "brand"
    t.string "formula_identifier", null: false
    t.string "supplier"
    t.date "effective_date"
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["code"], name: "index_materials_on_code", unique: true
    t.index ["material_category_id"], name: "index_materials_on_material_category_id"
  end

  create_table "project_actual_costs", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.string "category", null: false
    t.string "description"
    t.decimal "amount", precision: 14, scale: 2, null: false
    t.date "recorded_on", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_id"], name: "index_project_actual_costs_on_project_id"
  end

  create_table "project_floors", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "project_id", null: false
    t.integer "floor_number", null: false
    t.string "name"
    t.decimal "floor_height_ft", precision: 6, scale: 2, default: "10.0", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.decimal "footprint_percentage", precision: 5, scale: 2, default: "100.0", null: false
    t.integer "bhk_type"
    t.index ["project_id", "floor_number"], name: "index_project_floors_on_project_id_and_floor_number", unique: true
    t.index ["project_id"], name: "index_project_floors_on_project_id"
  end

  create_table "projects", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name"
    t.string "client_name"
    t.string "city"
    t.string "state"
    t.decimal "plot_length_ft", precision: 8, scale: 2
    t.decimal "plot_width_ft", precision: 8, scale: 2
    t.decimal "construction_length_ft", precision: 8, scale: 2
    t.decimal "construction_width_ft", precision: 8, scale: 2
    t.decimal "floors_count", precision: 4, scale: 1, default: "1.0", null: false
    t.integer "bhk_type", default: 0, null: false
    t.integer "construction_quality", default: 0, null: false
    t.integer "status", default: 0, null: false
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_projects_on_user_id"
  end

  create_table "rooms", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "project_floor_id", null: false
    t.integer "room_type", null: false
    t.string "name", null: false
    t.decimal "length_ft", precision: 6, scale: 2, null: false
    t.decimal "width_ft", precision: 6, scale: 2, null: false
    t.decimal "wall_height_ft", precision: 6, scale: 2, default: "10.0", null: false
    t.integer "door_count", default: 1, null: false
    t.integer "window_count", default: 1, null: false
    t.integer "electrical_point_count", default: 4, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_floor_id"], name: "index_rooms_on_project_floor_id"
  end

  create_table "users", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "name", default: "", null: false
    t.string "company_name"
    t.string "phone"
    t.integer "role", default: 0, null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role"], name: "index_users_on_role"
  end

  create_table "windows", charset: "utf8mb4", collation: "utf8mb4_0900_ai_ci", force: :cascade do |t|
    t.bigint "project_floor_id", null: false
    t.bigint "room_id"
    t.integer "window_type", null: false
    t.decimal "width_ft", precision: 5, scale: 2, null: false
    t.decimal "height_ft", precision: 5, scale: 2, null: false
    t.integer "quantity", default: 1, null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["project_floor_id"], name: "index_windows_on_project_floor_id"
    t.index ["room_id"], name: "index_windows_on_room_id"
  end

  add_foreign_key "audit_logs", "users"
  add_foreign_key "doors", "project_floors"
  add_foreign_key "doors", "rooms"
  add_foreign_key "estimate_line_items", "estimates"
  add_foreign_key "estimates", "construction_packages"
  add_foreign_key "estimates", "estimates", column: "previous_version_id"
  add_foreign_key "estimates", "projects"
  add_foreign_key "estimates", "users"
  add_foreign_key "formula_parameters", "calculation_formulas"
  add_foreign_key "material_rates", "materials"
  add_foreign_key "materials", "material_categories"
  add_foreign_key "project_actual_costs", "projects"
  add_foreign_key "project_floors", "projects"
  add_foreign_key "projects", "users"
  add_foreign_key "rooms", "project_floors"
  add_foreign_key "windows", "project_floors"
  add_foreign_key "windows", "rooms"
end
