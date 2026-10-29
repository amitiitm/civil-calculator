class AddBhkTypeToProjectFloors < ActiveRecord::Migration[8.1]
  def change
    add_column :project_floors, :bhk_type, :integer
  end
end
