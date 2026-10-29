class CreateMaterialCategories < ActiveRecord::Migration[8.0]
  def change
    create_table :material_categories do |t|
      t.string :name, null: false
      t.string :code, null: false
      t.text :description
      t.integer :position, default: 0, null: false

      t.timestamps
    end
    add_index :material_categories, :code, unique: true
  end
end
