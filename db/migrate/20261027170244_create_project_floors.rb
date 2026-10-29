class CreateProjectFloors < ActiveRecord::Migration[8.0]
  def change
    create_table :project_floors do |t|
      t.references :project, null: false, foreign_key: true
      t.integer :floor_number, null: false
      t.string :name
      t.decimal :floor_height_ft, precision: 6, scale: 2, default: 10, null: false

      t.timestamps
    end
    add_index :project_floors, [ :project_id, :floor_number ], unique: true
  end
end
