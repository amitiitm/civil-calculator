class CreateEstimates < ActiveRecord::Migration[8.0]
  def change
    create_table :estimates do |t|
      t.references :project, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true
      t.references :construction_package, null: true, foreign_key: true
      t.references :previous_version, null: true, foreign_key: { to_table: :estimates }
      t.integer :version_number, default: 1, null: false
      t.integer :status, default: 0, null: false
      t.decimal :material_cost, precision: 14, scale: 2, default: 0, null: false
      t.decimal :labour_cost, precision: 14, scale: 2, default: 0, null: false
      t.decimal :equipment_cost, precision: 14, scale: 2, default: 0, null: false
      t.decimal :transport_cost, precision: 14, scale: 2, default: 0, null: false
      t.decimal :contingency_percentage, precision: 5, scale: 2, default: 5, null: false
      t.decimal :contingency_amount, precision: 14, scale: 2, default: 0, null: false
      t.decimal :tax_amount, precision: 14, scale: 2, default: 0, null: false
      t.decimal :total_cost, precision: 14, scale: 2, default: 0, null: false
      t.decimal :cost_per_sqft, precision: 10, scale: 2, default: 0, null: false
      t.date :price_date, null: false
      t.text :assumptions_notes

      t.timestamps
    end
  end
end
