class CreateConstructionSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :construction_settings do |t|
      t.string :key, null: false
      t.string :value, null: false
      t.string :data_type, null: false, default: "string"
      t.string :group
      t.text :description

      t.timestamps
    end
    add_index :construction_settings, :key, unique: true
  end
end
