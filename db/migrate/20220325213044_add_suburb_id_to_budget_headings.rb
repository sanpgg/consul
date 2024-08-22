class AddSuburbIdToBudgetHeadings < ActiveRecord::Migration
  def change
    add_column :budget_headings, :suburb_id, :integer
  end
end
