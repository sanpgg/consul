Rails.application.routes.draw do

  get 'api/image_upload'

  mount Ckeditor::Engine => '/ckeditor'

  if Rails.env.development? || Rails.env.staging?
    get '/sandbox' => 'sandbox#index'
    get '/sandbox/*template' => 'sandbox#show'
  end

  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

  draw :account
  draw :admin
  draw :annotation
  draw :budget
  draw :comment
  draw :community
  draw :debate
  draw :devise
  draw :direct_upload
  draw :document
  draw :graphql
  draw :legislation
  draw :management
  draw :moderation
  draw :notification
  draw :officing
  draw :poll
  draw :proposal
  draw :related_content
  draw :tag
  draw :user
  draw :valuation
  draw :verification

  root 'welcome#index'

  get '/welcome', to: 'welcome#welcome'
  get '/consul.json', to: "installation#details"


  #API TO UPLOAD THE IFE
  put 'api/image_upload' => 'api#image_upload', as: :image_upload

  #TO UPLOAD ADDITIONAL IMAGES
  resources :additional_images, only: [:index, :create, :destroy]


  resources :stats, only: [:index]
  resources :images, only: [:destroy]
  resources :documents, only: [:destroy]
  resources :follows, only: [:create, :destroy]

  get '/mis_votos', to: 'my_votes#index'

  put 'account/update_profile', to: 'account#update_profile', as: :update_user_profile
  get 'account/complete_profile', to: 'account#complete_profile', as: 'complete_profile'
  get 'account/profile', to: 'account#profile', as: 'profile'
  get '/presupuestos/:budget_id/investment_create_step', to: 'budgets/investments#pre', as: 'investment_create_step'
  get '/presupuestos/:budget_id/autocomplete_investment_address', to: 'budgets/investments#autocomplete', as: 'autocomplete_investment_address'
  get '/presupuestos/:budget_id/geocode', to: 'budgets/investments#geocode', as: 'geocode'
  get '/presupuestos/:budget_id/reverse_geocode', to: 'budgets/investments#reverse_geocode', as: 'reverse_geocode'
  get '/presupuestos/:budget_id/investment/:investment_id/created', to: 'budgets/investments#created', as: 'budget_investment_created'
  get '/presupuestos/:budget_id/load_more_investments', to: 'budgets#load_more_investments', as: 'load_more_investments'

  # More info pages
  get 'ayuda',             to: 'pages#show', id: 'help/index',             as: 'help'
  get 'help/how-to-use',  to: 'pages#show', id: 'help/how_to_use/index',  as: 'how_to_use'
  get 'ayuda/preguntas-frecuentess',         to: 'pages#show', id: 'help/faq/index',         as: 'faq'

  # Static pages
  get '/blog' => redirect("http://blog.consul/")
  resources :pages, path: '/', only: [:show]
end
