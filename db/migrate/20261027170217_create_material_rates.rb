class CreateMaterialRates < ActiveRecord::Migration[8.0]
  def change
    create_table :material_rates do |t|
      t.references :material, null: false, foreign_key: true
      t.string :state
      t.string :city
      t.string :quality_grade
      t.decimal :rate, precision: 12, scale: 2, null: false
      t.date :effective_date, null: false

      t.timestamps
    end
    add_index :material_rates, [ :material_id, :state, :city, :quality_grade ], name: "index_material_rates_on_location_and_grade"
  end
end
