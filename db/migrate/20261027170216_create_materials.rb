class CreateMaterials < ActiveRecord::Migration[8.0]
  def change
    create_table :materials do |t|
      t.references :material_category, null: false, foreign_key: true
      t.string :code, null: false
      t.string :name, null: false
      t.string :unit, null: false
      t.decimal :default_rate, precision: 12, scale: 2, default: 0, null: false
      t.decimal :wastage_percentage, precision: 5, scale: 2, default: 0, null: false
      t.string :quality_grade
      t.string :brand
      t.string :formula_identifier, null: false
      t.string :supplier
      t.date :effective_date
      t.boolean :active, default: true, null: false

      t.timestamps
    end
    add_index :materials, :code, unique: true
  end
end
