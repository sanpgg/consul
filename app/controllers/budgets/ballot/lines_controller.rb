module Budgets
  module Ballot
    class LinesController < ApplicationController
      before_action :authenticate_user!
      #before_action :ensure_final_voting_allowed
      before_action :load_budget
      before_action :load_ballot
      before_action :load_tag_cloud
      before_action :load_categories
      before_action :load_investments
      before_action :load_ballot_referer

      load_and_authorize_resource :budget
      load_and_authorize_resource :ballot, class: "Budget::Ballot", through: :budget
      load_and_authorize_resource :line, through: :ballot, find_by: :investment_id, class: "Budget::Ballot::Line"

      def current_ballots
        ballots = Budget::Ballot.joins(lines: :investment).where(user: current_user, budget: current_budget, 'budget_ballot_lines.budget_id' => current_budget.id)
      end

      def has_line_by_investment_size(size)
        current_ballots&.any? { |ballot| ballot.lines.any? { |line| line.investment.size == size } }
      end

      def is_my_sector(sector)
        current_user.sector == sector
      end

      def create

        load_investment

        return redirect_to account_path, alert: 'No puedes votar porque tu perfil no está completo. Completa tu perfil.' unless current_user.level_three_verified?

        return redirect_to vota_path(current_budget), alert: 'No puedes votar por esta propuesta porque eres menor de edad.' if current_user.is_minor?

        return redirect_to vota_path(current_budget), alert: 'No puedes votar por esta propuesta. No es factible.' unless @investment.feasible?

        return redirect_to vota_path(current_budget), alert: 'Ya tienes un voto en una propuesta de este tamaño' if has_line_by_investment_size(@investment.size)

        return redirect_to vota_path(current_budget), alert: 'No puedes votar por esta propuesta. No es de tu sector' unless is_my_sector(@investment.author.colonium.first.sector)

        unless @budget.is_new?
          load_heading
          load_map
        end

        @ballot.add_investment(@investment)

        return redirect_to voted_path(current_budget, @investment), notice: 'Tu voto se ha registrado con éxito'
      end

      def destroy
        @investment = @line.investment

        unless @budget.is_new?
          load_heading
          load_map
        end

        @line.destroy
        load_investments

        return redirect_to vota_path(current_budget), notice: 'Tu voto se ha eliminado con éxito'
      end

      private

        def ensure_final_voting_allowed
          return head(:forbidden) unless @budget.balloting?
        end

        def line_params
          params.permit(:investment_id, :budget_id)
        end

        def load_budget
          @budget = Budget.find(params[:budget_id])
        end

        def load_ballot
          @ballot = Budget::Ballot.where(user: current_user, budget: @budget).first_or_create
        end

        def load_investment
          @investment = Budget::Investment.find(params[:investment_id])
        end

        def load_investments
          if params[:investments_ids].present?
            @investment_ids = params[:investments_ids]
            @investments = Budget::Investment.where(id: params[:investments_ids])
          end
        end

        def load_heading
          @heading = @investment.heading
        end

        def load_tag_cloud
          @tag_cloud = TagCloud.new(Budget::Investment, params[:search])
        end

        def load_categories
          @categories = ActsAsTaggableOn::Tag.category.order(:name)
        end

        def load_ballot_referer
          @ballot_referer = session[:ballot_referer]
        end

        def load_map
          @investments ||= []
          @investments_map_coordinates = MapLocation.where(investment: @investments).map(&:json_data)
          @map_location = MapLocation.load_from_heading(@heading)
        end

    end
  end
end
