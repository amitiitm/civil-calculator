class CreateRooms < ActiveRecord::Migration[8.0]
  def change
    create_table :rooms do |t|
      t.references :project_floor, null: false, foreign_key: true
      t.integer :room_type, null: false
      t.string :name, null: false
      t.decimal :length_ft, precision: 6, scale: 2, null: false
      t.decimal :width_ft, precision: 6, scale: 2, null: false
      t.decimal :wall_height_ft, precision: 6, scale: 2, default: 10, null: false
      t.integer :door_count, default: 1, null: false
      t.integer :window_count, default: 1, null: false
      t.integer :electrical_point_count, default: 4, null: false

      t.timestamps
    end
  end
end
