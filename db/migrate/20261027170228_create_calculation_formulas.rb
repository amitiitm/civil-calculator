class CreateCalculationFormulas < ActiveRecord::Migration[8.0]
  def change
    create_table :calculation_formulas do |t|
      t.string :category_code, null: false
      t.string :name, null: false
      t.string :formula_identifier, null: false
      t.integer :version, default: 1, null: false
      t.boolean :active, default: true, null: false
      t.text :description

      t.timestamps
    end
    add_index :calculation_formulas, [ :category_code, :version ], unique: true
  end
end
