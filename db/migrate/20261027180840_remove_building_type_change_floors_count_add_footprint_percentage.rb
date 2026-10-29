class RemoveBuildingTypeChangeFloorsCountAddFootprintPercentage < ActiveRecord::Migration[8.1]
  def change
    remove_column :projects, :building_type, :integer, default: 0, null: false
    change_column :projects, :floors_count, :decimal, precision: 4, scale: 1, default: "1.0", null: false

    add_column :project_floors, :footprint_percentage, :decimal, precision: 5, scale: 2, default: "100.0", null: false
  end
end
