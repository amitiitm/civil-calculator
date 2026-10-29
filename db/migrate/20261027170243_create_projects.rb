class CreateProjects < ActiveRecord::Migration[8.0]
  def change
    create_table :projects do |t|
      t.references :user, null: false, foreign_key: true
      t.string :name
      t.string :client_name
      t.string :city
      t.string :state
      t.decimal :plot_length_ft, precision: 8, scale: 2
      t.decimal :plot_width_ft, precision: 8, scale: 2
      t.decimal :construction_length_ft, precision: 8, scale: 2
      t.decimal :construction_width_ft, precision: 8, scale: 2
      t.integer :floors_count, default: 1, null: false
      t.integer :building_type, default: 0, null: false
      t.integer :bhk_type, default: 0, null: false
      t.integer :construction_quality, default: 0, null: false
      t.integer :status, default: 0, null: false
      t.text :notes

      t.timestamps
    end
  end
end
