module Budgets
  class ResultsController < ApplicationController
    before_action :load_budget
    before_action :load_heading

    load_and_authorize_resource :budget

    def show
      authorize! :read_results, @budget
      
      if @budget.is_new?

        @investments = @budget.investments.feasible.sort_by_ballots.winners

        # Si el usuario está con sesión iniciada mostrar por defecto las de su sector
        # Recibir como parámetro el sector
        # Recibir como parámetro si mostrar o no las No Ganadoras
        # Buscador

        unless params.nil?

          if params[:status].present?
            @investments = @budget.investments.feasible.sort_by_ballots if params[:status] == 'inw'
          end

          if params[:query].present?
            @investments = @investments.search_v2(params[:query]).order(budget_id: :asc)
          end

          if params[:s].present?
              @investments = @investments.by_sector_v2(User.sector.find_value(params[:s]).value) unless params[:s] == 'all'
          end
  
          if params[:size].present?
            @investments = @investments.by_size(params[:size])
          end
        end

        @investments = @investments.sort_by { |record| -record.total_votes_v2 }

      else
        @investments = Budget::Result.new(@budget, @heading).investments
      end

    end

    private

      def load_budget
        @budget = Budget.find_by(id: params[:budget_id])
      end

      def load_heading
        @heading = if params[:heading_id].present?
                     @budget.headings.find(params[:heading_id])
                   else
                     @budget.headings.first
                   end
      end

  end
end
