class AddIsActiveToColonium < ActiveRecord::Migration
  def change
    add_column :colonia, :is_active, :boolean
  end
end
