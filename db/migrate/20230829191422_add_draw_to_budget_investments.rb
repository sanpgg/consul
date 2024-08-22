class AddDrawToBudgetInvestments < ActiveRecord::Migration
  def change
    add_column :budget_investments, :draw, :bool
  end
end
