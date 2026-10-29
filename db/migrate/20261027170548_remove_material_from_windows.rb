class RemoveMaterialFromWindows < ActiveRecord::Migration[8.0]
  def change
    remove_column :windows, :material, :integer
  end
end
