class CreateEstimateLineItems < ActiveRecord::Migration[8.0]
  def change
    create_table :estimate_line_items do |t|
      t.references :estimate, null: false, foreign_key: true
      t.string :material_category_name, null: false
      t.string :item_name, null: false
      t.string :unit, null: false
      t.decimal :raw_quantity, precision: 14, scale: 4, default: 0, null: false
      t.decimal :purchase_quantity, precision: 14, scale: 4, default: 0, null: false
      t.decimal :rate, precision: 12, scale: 2, default: 0, null: false
      t.decimal :amount, precision: 14, scale: 2, default: 0, null: false
      t.integer :item_type, default: 0, null: false
      t.integer :data_source, default: 0, null: false
      t.string :floor_label
      t.string :formula_identifier, null: false

      t.timestamps
    end
  end
end
