class AddSizeToBudgetInvestments < ActiveRecord::Migration
  def change
    add_column :budget_investments, :size, :string
  end
end
