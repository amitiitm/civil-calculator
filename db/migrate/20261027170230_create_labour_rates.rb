class CreateLabourRates < ActiveRecord::Migration[8.0]
  def change
    create_table :labour_rates do |t|
      t.string :work_type
      t.string :unit
      t.decimal :rate, precision: 12, scale: 2
      t.string :city
      t.string :state
      t.string :quality_grade
      t.boolean :active, default: true, null: false

      t.timestamps
    end
  end
end
