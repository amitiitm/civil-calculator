class CreateWindows < ActiveRecord::Migration[8.0]
  def change
    create_table :windows do |t|
      t.references :project_floor, null: false, foreign_key: true
      t.references :room, null: true, foreign_key: true
      t.integer :window_type, null: false
      t.integer :material, null: false
      t.decimal :width_ft, precision: 5, scale: 2, null: false
      t.decimal :height_ft, precision: 5, scale: 2, null: false
      t.integer :quantity, default: 1, null: false

      t.timestamps
    end
  end
end
