get '/budgets/:budget_id/investments/:id' => 'budgets/investments#show'

resources :investments,
          controller: "budgets/investments",
          only: [:index],
          path: "propuestas"

resources :budgets, only: [:show, :index], :path => "presupuestos" do
  resources :groups, controller: "budgets/groups", only: [:show]
  resources :investments, controller: "budgets/investments", only: [:index, :new, :create, :show, :destroy, :edit, :update] do

    resource :like, module: :investments

    member do
      post :vote
      put :flag
      put :unflag
    end

    collection { get :suggest }
  end

  resource :ballot, only: :show, controller: "budgets/ballots" do
    resources :lines, controller: "budgets/ballot/lines", only: [:create, :destroy]
  end

  resource :results, only: :show, controller: "budgets/results"
  resource :executions, only: :show, controller: 'budgets/executions'
end

scope '/participatory_budget' do
  resources :spending_proposals, only: [:index, :new, :create, :show, :destroy], path: 'investment_projects' do
    post :vote, on: :member
  end
end

get 'investments/:id/json_data', action: :json_data, controller: 'budgets/investments'
get '/budgets/:budget_id/investments/:id/json_data', action: :json_data, controller: 'budgets/investments'

get '/presupuestos/:budget_id/ballot/load_more_investments', to: 'budgets/ballots#load_more_investments', as: 'load_more_investments_b'

get '/presupuestos/:budget_id/investments/:id/voted', to: 'budgets/ballots#voted', as: 'voted'
get '/presupuestos/:budget_id/votes', to: 'budgets/ballots#index', as: 'current_votes'
get '/presupuestos/:budget_id/vota', to: 'budgets/ballots#vota', as: 'vota'