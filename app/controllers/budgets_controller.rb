class BudgetsController < ApplicationController
  include FeatureFlags
  include BudgetsHelper
  feature_flag :budgets

  load_and_authorize_resource
  before_action :set_default_budget_filter, only: :show
  has_filters %w{not_unfeasible feasible unfeasible unselected selected}, only: :show

  respond_to :html, :js

  def show
    raise ActionController::RoutingError, 'Not Found' unless budget_published?(@budget)
  end

  def index
    # Limpiar y manejar correctamente los parámetros de array
    selected_sectors = Array(params[:s])
    selected_sizes = Array(params[:size])
    selected_status= Array(params[:status])

    @investments = Budget::Investment.all.order(budget_id: :desc).uniq
    filter_investments

    @all_investments_map = all_investments_map_new(@investments).to_json
    @investments = @investments.page(params[:page] || 1).per(15)
  end

  def load_more_investments
    # Limpiar y manejar correctamente los parámetros de array
    selected_sectors = Array(params[:s])
    selected_sizes = Array(params[:size])
    selected_status= Array(params[:status])

    @investments = Budget::Investment.all.order(budget_id: :desc).uniq
    filter_investments

    @investments = @investments.page(params[:page]).per(15)

    respond_to do |format|
      format.js { render 'load_more_investments', collection: @investments }
    end
  end

  private

  def filter_investments
    if params[:query].present?
      @investments = @investments.search_v2(params[:query]).order(budget_id: :asc)
    end

    if params[:ppy].present?
      @investments = @investments.joins(:budget).merge(Budget.by_year(params[:ppy]))
    end

    if params[:status].present?
      case params[:status]
      when 'w'
        @investments = @investments.winners
      when 'nw'
        @investments = @investments.no_winners
      when 'f'
        @investments = @investments.feasible
      when 'uf'
        @investments = @investments.unfeasible
      end
    end

    if params[:s].present?
      if only_sector?
        unless params[:s] == 'all'
          sector_investments = investments_by_sector(params[:s]).where(budget_id: current_budget.id)
          winners_from_other_budgets = Budget::Investment.winners.where.not(budget_id: current_budget.id).order(budget_id: :desc).by_sector_v2(User.sector.find_value(params[:s]).value)
          combined_investments = sector_investments.to_a + winners_from_other_budgets.to_a
          combined_investments = combined_investments.sort_by(&:budget_id).reverse
          @investments = Kaminari.paginate_array(combined_investments)
        end
      else
        @investments = investments_by_sector(params[:s])
      end
    end

    if params[:size].present?
      if only_size?
        @investments = @investments.by_size(params[:size]).where(budget_id: current_budget.id)
      else
        @investments = @investments.by_size(params[:size])
      end
    end

    if all?
      @investments = @investments.where(budget_id: current_budget.id)
    end
  end

  def all?
    params[:query].blank? && params[:ppy].blank? && params[:status].blank? && params[:s].blank? && params[:size].blank?
  end

  def only_sector?
    params[:query].blank? && params[:ppy].blank? && params[:status].blank? && params[:s].present? && params[:size].blank?
  end

  def only_size?
    params[:query].blank? && params[:ppy].blank? && params[:status].blank? && params[:s].blank? && params[:size].present?
  end

  def investments_by_sector(sector)
    return @investments if sector == 'all'
    @investments.by_sector_v2(User.sector.find_value(sector).value)
  end

  def investments_by_user_sector
    user_sector = current_user.colonium.first.sector
    @investments.by_sector_v2(User.sector.find_value(user_sector).value)
  end
end
