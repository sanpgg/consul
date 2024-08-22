module Budgets
  class BallotsController < ApplicationController
    before_action :authenticate_user!
    load_and_authorize_resource :budget
    before_action :load_ballot
    after_action :store_referer, only: [:show]

    def show
      session[:ballot_referer] = request.referer
      @investments = load_investments
      render template: "budgets/ballot/show"
    end

    def load_investments

      @investments = investments_by_user_sector.includes(:tags).where(budget_id: current_budget.id).selected
  
      @investments = @investments.feasible
  
      if params[:query].present?
        @investments = @investments.search_v2(params[:query]).order(budget_id: :desc)
      end

      if params[:size].present?
          @investments = @investments.by_size(params[:size])
      end

      if params[:categorias].present?
        @investments = @investments.by_tag(params[:categorias])
      end

      @investments = @investments.page(1).per(15)
    end

    def load_more_investments
      @investments = investments_by_user_sector.where(budget_id: current_budget.id).selected
  
      @investments = @investments.feasible

      if params[:query].present?
        @investments = @investments.search_v2(params[:query]).order(budget_id: :desc)
      end

      if params[:size].present?
        @investments = @investments.by_size(params[:size])
      end

      if params[:categorias].present?
        @investments = @investments.by_tag(params[:categorias])
      end
    
      @investments = @investments.page(params[:page]).per(15)
    
      respond_to do |format|
        format.js { render 'budgets/ballot/load_more_investments_b', collection: @investments }
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
  
    def investments_by_user_sector
      user_sector = current_user.colonium.first.sector
      current_budget.investments.by_sector_v2(User.sector.find_value(user_sector).value)
    end

    def voted
    end

    def index
    end

    def vota
      #session[:ballot_referer] = request.referer
      @investments = load_investments
      #render template: "budgets/ballot/show"
    end

    private

      def load_ballot
        query = Budget::Ballot.where(user: current_user, budget: @budget)
        @ballot = @budget.balloting? ? query.first_or_create : query.first_or_initialize
      end

      def store_referer
        session[:ballot_referer] = request.referer
      end
  end
end
