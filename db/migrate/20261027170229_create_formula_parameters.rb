class CreateFormulaParameters < ActiveRecord::Migration[8.0]
  def change
    create_table :formula_parameters do |t|
      t.references :calculation_formula, null: false, foreign_key: true
      t.string :key, null: false
      t.decimal :value, precision: 14, scale: 4, null: false
      t.string :data_type, default: "decimal", null: false

      t.timestamps
    end
    add_index :formula_parameters, [ :calculation_formula_id, :key ], unique: true, name: "index_formula_parameters_on_formula_and_key"
  end
end
