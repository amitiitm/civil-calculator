class CreateConstructionPackages < ActiveRecord::Migration[8.0]
  def change
    create_table :construction_packages do |t|
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.decimal :rate_per_sqft, precision: 12, scale: 2, default: 0, null: false
      t.integer :position, default: 0, null: false
      t.boolean :active, default: true, null: false

      t.timestamps
    end
    add_index :construction_packages, :slug, unique: true
  end
end
