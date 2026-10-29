class CreateProjectActualCosts < ActiveRecord::Migration[8.0]
  def change
    create_table :project_actual_costs do |t|
      t.references :project, null: false, foreign_key: true
      t.string :category, null: false
      t.string :description
      t.decimal :amount, precision: 14, scale: 2, null: false
      t.date :recorded_on, null: false

      t.timestamps
    end
  end
end
