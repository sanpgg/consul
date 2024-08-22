module BallotsHelper

  def progress_bar_width(amount_available, amount_spent)
    (amount_spent / amount_available.to_f * 100).to_s + "%"
  end

  def current_ballots
    ballots = Budget::Ballot.joins(lines: :investment).where(user: current_user, budget: current_budget, 'budget_ballot_lines.budget_id' => current_budget.id)
  end
  
  def has_line_by_investment_size(size)
    current_ballots&.any? { |ballot| ballot.lines.any? { |line| line.investment.size == size } }
  end

end